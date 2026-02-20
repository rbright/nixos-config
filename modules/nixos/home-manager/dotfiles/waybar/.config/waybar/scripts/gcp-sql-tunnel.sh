#!/usr/bin/env bash
set -euo pipefail

STARTING_GRACE_SECONDS=20
RECENT_ERROR_WINDOW_SECONDS=$((5 * 60))
LOG_TAIL_LINES=20

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/waybar/gcp-sql-tunnel"
PID_PATH="$STATE_DIR/tunnel.pid"
STATE_PATH="$STATE_DIR/tunnel-state.json"
LOG_PATH="$STATE_DIR/tunnel.log"
CONFIG_PATH="${GCP_SQL_TUNNEL_ENV_FILE:-${XDG_CONFIG_HOME:-$HOME/.config}/waybar/gcp-sql-tunnel.env}"

DB_PRIVATE_IP=""
BASTION_INSTANCE=""
BASTION_ZONE=""
LOCAL_PORT="15432"
REMOTE_PORT="5432"
GCLOUD_PATH=""
CONFIG_ERROR=""

usage() {
  cat <<'EOF'
Usage: gcp-sql-tunnel.sh <status|start|stop|restart|reset|open-log|copy-local>
EOF
}

ensure_state_dir() {
  mkdir -p "$STATE_DIR"
}

now_iso() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

json_escape() {
  local value="$1"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  value="${value//$'\n'/\\n}"
  value="${value//$'\r'/}"
  value="${value//$'\t'/\\t}"
  printf '%s' "$value"
}

json_string_or_null() {
  local value="$1"
  if [[ -n "$value" ]]; then
    printf '"%s"' "$(json_escape "$value")"
  else
    printf 'null'
  fi
}

json_number_or_null() {
  local value="$1"
  if [[ "$value" =~ ^[0-9]+$ ]]; then
    printf '%s' "$value"
  else
    printf 'null'
  fi
}

print_status_json() {
  local text="$1"
  local tooltip="$2"
  local class_name="$3"

  printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' \
    "$(json_escape "$text")" \
    "$(json_escape "$tooltip")" \
    "$(json_escape "$class_name")"
}

append_log() {
  ensure_state_dir
  printf '[%s] %s\n' "$(now_iso)" "$1" >> "$LOG_PATH"
}

notify() {
  local message="$1"
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "GCP SQL Tunnel" "$message" >/dev/null 2>&1 || true
  fi
}

state_get() {
  local key="$1"

  [[ -f "$STATE_PATH" ]] || return 0

  if command -v jq >/dev/null 2>&1; then
    jq -r --arg key "$key" '.[$key] // empty' "$STATE_PATH" 2>/dev/null || true
    return 0
  fi

  awk -v key="$key" '
    match($0, "\\\"" key "\\\"[[:space:]]*:[[:space:]]*\\\"([^\\\"]*)\\\"", m) {
      print m[1]
      exit
    }
    match($0, "\\\"" key "\\\"[[:space:]]*:[[:space:]]*([0-9]+)", m) {
      print m[1]
      exit
    }
  ' "$STATE_PATH" 2>/dev/null || true
}

write_state() {
  local last_start_at="$1"
  local last_stop_at="$2"
  local last_pid="$3"

  ensure_state_dir

  local tmp_file
  tmp_file="$(mktemp)"

  {
    printf '{\n'
    printf '  "lastStartAt": %s,\n' "$(json_string_or_null "$last_start_at")"
    printf '  "lastStopAt": %s,\n' "$(json_string_or_null "$last_stop_at")"
    printf '  "lastPid": %s\n' "$(json_number_or_null "$last_pid")"
    printf '}\n'
  } > "$tmp_file"

  mv "$tmp_file" "$STATE_PATH"
}

read_pid() {
  [[ -f "$PID_PATH" ]] || return 0

  local pid
  pid="$(tr -d '[:space:]' < "$PID_PATH")"
  if [[ "$pid" =~ ^[0-9]+$ ]]; then
    printf '%s\n' "$pid"
  fi
}

write_pid() {
  local pid="$1"
  ensure_state_dir
  printf '%s\n' "$pid" > "$PID_PATH"
}

clear_pid() {
  rm -f "$PID_PATH"
}

is_pid_running() {
  local pid="$1"
  kill -0 "$pid" 2>/dev/null
}

port_open() {
  local port="$1"

  if command -v timeout >/dev/null 2>&1; then
    timeout 0.5 bash -c "exec 3<>/dev/tcp/127.0.0.1/$port" >/dev/null 2>&1
    return $?
  fi

  bash -c "exec 3<>/dev/tcp/127.0.0.1/$port" >/dev/null 2>&1
}

wait_for_pid_exit() {
  local pid="$1"
  local max_attempts="${2:-15}"

  local attempt=0
  while (( attempt < max_attempts )); do
    if ! is_pid_running "$pid"; then
      return 0
    fi

    sleep 0.1
    attempt=$((attempt + 1))
  done

  return 1
}

wait_for_port_closed() {
  local port="$1"
  local max_attempts="${2:-10}"

  local attempt=0
  while (( attempt < max_attempts )); do
    if ! port_open "$port"; then
      return 0
    fi

    sleep 0.2
    attempt=$((attempt + 1))
  done

  return 1
}

terminate_pid() {
  local pid="$1"

  if ! is_pid_running "$pid"; then
    return 0
  fi

  if ! kill -TERM -- "-$pid" 2>/dev/null; then
    kill -TERM "$pid" 2>/dev/null || true
  fi

  wait_for_pid_exit "$pid" 15 || true

  if is_pid_running "$pid"; then
    if ! kill -KILL -- "-$pid" 2>/dev/null; then
      kill -KILL "$pid" 2>/dev/null || true
    fi

    wait_for_pid_exit "$pid" 10 || true
  fi
}

to_epoch() {
  local value="$1"
  [[ -n "$value" ]] || return 1
  date --date "$value" +%s 2>/dev/null
}

resolve_status() {
  local is_port_open="$1"
  local is_pid_alive="$2"
  local last_start_at="$3"
  local last_stop_at="$4"

  if [[ "$is_port_open" == "1" ]]; then
    printf 'connected\n'
    return 0
  fi

  local now_epoch
  now_epoch="$(date +%s)"

  local started_epoch=""
  local stopped_epoch=""

  started_epoch="$(to_epoch "$last_start_at" 2>/dev/null || true)"
  stopped_epoch="$(to_epoch "$last_stop_at" 2>/dev/null || true)"

  local has_recent_start=0
  local has_recent_error_window=0
  local stop_after_start=0

  if [[ -n "$started_epoch" ]]; then
    if (( now_epoch - started_epoch < STARTING_GRACE_SECONDS )); then
      has_recent_start=1
    fi

    if (( now_epoch - started_epoch < RECENT_ERROR_WINDOW_SECONDS )); then
      has_recent_error_window=1
    fi
  fi

  if [[ -n "$started_epoch" && -n "$stopped_epoch" ]]; then
    if (( stopped_epoch >= started_epoch )); then
      stop_after_start=1
    fi
  fi

  if [[ "$is_pid_alive" == "0" ]]; then
    if (( stop_after_start == 1 )); then
      printf 'disconnected\n'
      return 0
    fi

    if (( has_recent_error_window == 1 )); then
      printf 'error\n'
      return 0
    fi

    printf 'disconnected\n'
    return 0
  fi

  if (( has_recent_start == 1 )); then
    printf 'starting\n'
    return 0
  fi

  printf 'error\n'
}

status_label() {
  case "$1" in
    connected) printf 'Connected' ;;
    starting) printf 'Starting' ;;
    error) printf 'Error' ;;
    *) printf 'Disconnected' ;;
  esac
}

status_icon() {
  case "$1" in
    connected) printf '󰪥' ;;
    starting) printf '󱍸' ;;
    error) printf '󰅚' ;;
    *) printf '󱙜' ;;
  esac
}

read_log_tail() {
  [[ -f "$LOG_PATH" ]] || return 0
  tail -n "$LOG_TAIL_LINES" "$LOG_PATH" 2>/dev/null || true
}

is_valid_port() {
  local value="$1"
  [[ "$value" =~ ^[0-9]+$ ]] || return 1
  (( value >= 1 && value <= 65535 ))
}

load_config() {
  DB_PRIVATE_IP=""
  BASTION_INSTANCE=""
  BASTION_ZONE=""
  LOCAL_PORT="15432"
  REMOTE_PORT="5432"
  GCLOUD_PATH=""
  CONFIG_ERROR=""

  if [[ -f "$CONFIG_PATH" ]]; then
    # shellcheck disable=SC1090
    source "$CONFIG_PATH"
  else
    CONFIG_ERROR="Config file not found: $CONFIG_PATH"
  fi

  DB_PRIVATE_IP="$(trim "${DB_PRIVATE_IP:-}")"
  BASTION_INSTANCE="$(trim "${BASTION_INSTANCE:-}")"
  BASTION_ZONE="$(trim "${BASTION_ZONE:-}")"
  LOCAL_PORT="$(trim "${LOCAL_PORT:-15432}")"
  REMOTE_PORT="$(trim "${REMOTE_PORT:-5432}")"
  GCLOUD_PATH="$(trim "${GCLOUD_PATH:-}")"

  local missing=()
  [[ -n "$DB_PRIVATE_IP" ]] || missing+=("DB_PRIVATE_IP")
  [[ -n "$BASTION_INSTANCE" ]] || missing+=("BASTION_INSTANCE")
  [[ -n "$BASTION_ZONE" ]] || missing+=("BASTION_ZONE")

  if ((${#missing[@]} > 0)); then
    local suffix
    suffix="Missing required keys: ${missing[*]}"
    if [[ -n "$CONFIG_ERROR" ]]; then
      CONFIG_ERROR="$CONFIG_ERROR; $suffix"
    else
      CONFIG_ERROR="$suffix"
    fi
  fi

  if ! is_valid_port "$LOCAL_PORT"; then
    local suffix="LOCAL_PORT must be an integer between 1 and 65535"
    if [[ -n "$CONFIG_ERROR" ]]; then
      CONFIG_ERROR="$CONFIG_ERROR; $suffix"
    else
      CONFIG_ERROR="$suffix"
    fi
  fi

  if ! is_valid_port "$REMOTE_PORT"; then
    local suffix="REMOTE_PORT must be an integer between 1 and 65535"
    if [[ -n "$CONFIG_ERROR" ]]; then
      CONFIG_ERROR="$CONFIG_ERROR; $suffix"
    else
      CONFIG_ERROR="$suffix"
    fi
  fi
}

require_valid_config() {
  if [[ -z "$CONFIG_ERROR" ]]; then
    return 0
  fi

  append_log "Configuration error: $CONFIG_ERROR"
  printf 'gcp-sql-tunnel: %s\n' "$CONFIG_ERROR" >&2
  return 1
}

resolve_gcloud_path() {
  if [[ -n "$GCLOUD_PATH" ]]; then
    if [[ -x "$GCLOUD_PATH" ]]; then
      printf '%s\n' "$GCLOUD_PATH"
      return 0
    fi

    if command -v "$GCLOUD_PATH" >/dev/null 2>&1; then
      command -v "$GCLOUD_PATH"
      return 0
    fi
  fi

  local candidates=(
    "/run/current-system/sw/bin/gcloud"
    "/etc/profiles/per-user/$USER/bin/gcloud"
    "/opt/homebrew/bin/gcloud"
    "/usr/local/bin/gcloud"
    "/usr/bin/gcloud"
  )

  local candidate=""
  for candidate in "${candidates[@]}"; do
    if [[ -x "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  if command -v gcloud >/dev/null 2>&1; then
    command -v gcloud
    return 0
  fi

  return 1
}

command_preview() {
  local escaped=()
  local item=""
  for item in "$@"; do
    escaped+=("$(printf '%q' "$item")")
  done
  printf '%s' "${escaped[*]}"
}

read_runtime_state() {
  local pid=""
  local pid_running=0

  pid="$(read_pid || true)"
  if [[ -n "$pid" ]]; then
    if is_pid_running "$pid"; then
      pid_running=1
    else
      clear_pid
      pid=""
      pid_running=0
    fi
  fi

  local is_port_open=0
  if port_open "$LOCAL_PORT"; then
    is_port_open=1
  fi

  local last_start_at=""
  local last_stop_at=""
  last_start_at="$(state_get "lastStartAt")"
  last_stop_at="$(state_get "lastStopAt")"

  local status=""
  status="$(resolve_status "$is_port_open" "$pid_running" "$last_start_at" "$last_stop_at")"

  printf '%s|%s|%s|%s|%s|%s\n' \
    "$status" "$pid" "$pid_running" "$is_port_open" "$last_start_at" "$last_stop_at"
}

status_command() {
  load_config
  ensure_state_dir

  local runtime=""
  runtime="$(read_runtime_state)"

  local status=""
  local pid=""
  local pid_running=""
  local is_port_open=""
  local last_start_at=""
  local last_stop_at=""

  IFS='|' read -r status pid pid_running is_port_open last_start_at last_stop_at <<< "$runtime"

  if [[ -n "$CONFIG_ERROR" && "$status" != "connected" && "$status" != "starting" ]]; then
    status="error"
  fi

  local tooltip
  tooltip="Google Cloud SQL Tunnel: $(status_label "$status")"
  tooltip+=$'\n'
  tooltip+="Local: 127.0.0.1:$LOCAL_PORT"

  if [[ -n "$DB_PRIVATE_IP" ]]; then
    tooltip+=$'\n'
    tooltip+="Remote: $DB_PRIVATE_IP:$REMOTE_PORT"
  fi

  tooltip+=$'\n'
  tooltip+="Port open: $([[ "$is_port_open" == "1" ]] && printf 'yes' || printf 'no')"

  if [[ -n "$pid" ]]; then
    tooltip+=$'\n'
    tooltip+="PID: $pid"
  fi

  if [[ -n "$last_start_at" ]]; then
    tooltip+=$'\n'
    tooltip+="Last start: $last_start_at"
  fi

  if [[ -n "$last_stop_at" ]]; then
    tooltip+=$'\n'
    tooltip+="Last stop: $last_stop_at"
  fi

  if [[ -n "$CONFIG_ERROR" ]]; then
    tooltip+=$'\n\n'
    tooltip+="Config error: $CONFIG_ERROR"
  fi

  if [[ "$status" == "error" ]]; then
    local tail
    tail="$(read_log_tail)"
    if [[ -n "$tail" ]]; then
      tooltip+=$'\n\nRecent logs:'
      tooltip+=$'\n'
      tooltip+="$tail"
    fi
  fi

  print_status_json "$(status_icon "$status")" "$tooltip" "$status"
}

start_command() {
  load_config
  ensure_state_dir
  touch "$LOG_PATH"

  local runtime=""
  runtime="$(read_runtime_state)"

  local status=""
  local pid=""
  local pid_running=""
  local is_port_open=""
  local last_start_at=""
  local last_stop_at=""

  IFS='|' read -r status pid pid_running is_port_open last_start_at last_stop_at <<< "$runtime"

  if [[ "$status" == "connected" || "$status" == "starting" ]]; then
    append_log "Start skipped: tunnel already $status."
    exit 0
  fi

  if ! require_valid_config; then
    write_state "$(now_iso)" "$last_stop_at" ""
    exit 1
  fi

  local gcloud_bin=""
  if ! gcloud_bin="$(resolve_gcloud_path)"; then
    local msg="Unable to locate gcloud binary. Set GCLOUD_PATH or add gcloud to PATH."
    append_log "$msg"
    write_state "$(now_iso)" "$last_stop_at" ""
    printf 'gcp-sql-tunnel: %s\n' "$msg" >&2
    exit 1
  fi

  local args=(
    compute
    ssh
    "$BASTION_INSTANCE"
    "--zone=$BASTION_ZONE"
    --tunnel-through-iap
    --quiet
    --
    -N
    -L
    "127.0.0.1:${LOCAL_PORT}:${DB_PRIVATE_IP}:${REMOTE_PORT}"
    -o
    ExitOnForwardFailure=yes
    -o
    BatchMode=yes
    -o
    StrictHostKeyChecking=accept-new
    -o
    ServerAliveInterval=30
    -o
    ServerAliveCountMax=3
  )

  append_log "Starting tunnel..."
  append_log "Command: $(command_preview "$gcloud_bin" "${args[@]}")"

  local started_at
  started_at="$(now_iso)"

  setsid "$gcloud_bin" "${args[@]}" >> "$LOG_PATH" 2>&1 < /dev/null &
  local child_pid=$!

  write_pid "$child_pid"
  write_state "$started_at" "$last_stop_at" "$child_pid"

  sleep 0.4
  if ! is_pid_running "$child_pid"; then
    append_log "Tunnel process exited shortly after start."
  fi
}

stop_command() {
  load_config
  ensure_state_dir
  touch "$LOG_PATH"

  local pid=""
  pid="$(read_pid || true)"

  local last_start_at=""
  local last_stop_at=""
  last_start_at="$(state_get "lastStartAt")"
  last_stop_at="$(state_get "lastStopAt")"

  if [[ -n "$pid" ]]; then
    append_log "Stopping tunnel (pid $pid)..."
    terminate_pid "$pid"
  else
    append_log "Stopping tunnel: no active PID file found."
  fi

  clear_pid

  local stopped_at
  stopped_at="$(now_iso)"
  write_state "$last_start_at" "$stopped_at" ""

  wait_for_port_closed "$LOCAL_PORT" 10 || true
}

restart_command() {
  stop_command
  start_command
}

open_log_command() {
  ensure_state_dir
  touch "$LOG_PATH"

  if command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$LOG_PATH" >/dev/null 2>&1 &
    exit 0
  fi

  if command -v wezterm >/dev/null 2>&1; then
    wezterm start -- bash -lc "tail -n 120 -f $(printf '%q' "$LOG_PATH")" >/dev/null 2>&1 &
    exit 0
  fi

  printf '%s\n' "$LOG_PATH"
}

copy_local_command() {
  load_config

  local value="127.0.0.1:$LOCAL_PORT"

  if command -v wl-copy >/dev/null 2>&1; then
    printf '%s' "$value" | wl-copy --trim-newline
    notify "Copied $value"
    exit 0
  fi

  if command -v xclip >/dev/null 2>&1; then
    printf '%s' "$value" | xclip -selection clipboard
    notify "Copied $value"
    exit 0
  fi

  if command -v xsel >/dev/null 2>&1; then
    printf '%s' "$value" | xsel --clipboard --input
    notify "Copied $value"
    exit 0
  fi

  local msg="No clipboard utility found (expected wl-copy, xclip, or xsel)."
  append_log "$msg"
  printf 'gcp-sql-tunnel: %s\n' "$msg" >&2
  exit 1
}

command="${1:-status}"

case "$command" in
  status)
    status_command
    ;;
  start)
    start_command
    ;;
  stop)
    stop_command
    ;;
  restart|reset)
    restart_command
    ;;
  open-log)
    open_log_command
    ;;
  copy-local)
    copy_local_command
    ;;
  -h|--help|help)
    usage
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac
