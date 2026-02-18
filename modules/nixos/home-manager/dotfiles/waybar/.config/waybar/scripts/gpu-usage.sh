#!/usr/bin/env bash
set -euo pipefail

print_json() {
  local text="$1"
  local tooltip="$2"
  local class_name="$3"

  printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "$text" "$tooltip" "$class_name"
}

read_nvidia_usage() {
  command -v nvidia-smi >/dev/null 2>&1 || return 1

  local output=""
  if command -v timeout >/dev/null 2>&1; then
    output="$(timeout 1s nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null || true)"
  else
    output="$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null || true)"
  fi

  local avg=""
  avg="$({
    awk -F',' '
      {
        gsub(/[%[:space:]]/, "", $1)
        if ($1 ~ /^[0-9]+(\.[0-9]+)?$/) {
          sum += $1
          count += 1
        }
      }
      END {
        if (count > 0) {
          printf "%.0f", sum / count
        }
      }
    ' <<<"$output"
  } 2>/dev/null)"

  [[ -n "$avg" ]] || return 1
  printf '%s\n' "$avg"
}

read_sysfs_usage() {
  shopt -s nullglob
  local files=(
    /sys/class/drm/card*/device/gpu_busy_percent
    /sys/class/drm/card*/device/gt_busy_percent
  )

  local sum=0
  local count=0
  local file=""
  local value=""

  for file in "${files[@]}"; do
    [[ -r "$file" ]] || continue

    value="$(tr -d '[:space:]' < "$file")"
    if [[ "$value" =~ ^[0-9]+$ ]]; then
      sum=$((sum + value))
      count=$((count + 1))
    fi
  done

  shopt -u nullglob

  if ((count > 0)); then
    printf '%s\n' "$((sum / count))"
    return 0
  fi

  return 1
}

usage=""
if usage="$(read_nvidia_usage)"; then
  print_json "${usage}%" "GPU usage (NVIDIA avg): ${usage}%" "nvidia"
elif usage="$(read_sysfs_usage)"; then
  print_json "${usage}%" "GPU usage (sysfs avg): ${usage}%" "sysfs"
else
  print_json "--" "GPU usage unavailable on this host" "unavailable"
fi
