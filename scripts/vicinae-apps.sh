#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/vicinae-apps.sh [search-term]

List discoverable Vicinae application entrypoint IDs (and app names).
If [search-term] is provided, filter results by case-insensitive substring
match against either ID or name.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if (( $# > 1 )); then
  usage >&2
  exit 2
fi

search_term="${1:-}"

desktop_value() {
  local desktop_file="$1"
  local key="$2"

  awk -F= -v key="$key" '
    $0 ~ "^[[:space:]]*" key "=" {
      sub(/^[[:space:]]*[^=]*=/, "", $0)
      print $0
      exit
    }
  ' "$desktop_file"
}

is_true() {
  case "${1,,}" in
    1|true|yes)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

declare -a app_dirs=()
declare -A seen_dirs=()

auto_add_dir() {
  local dir="$1"

  [[ -n "$dir" ]] || return 0
  [[ -d "$dir" ]] || return 0

  if [[ -n "${seen_dirs[$dir]+x}" ]]; then
    return 0
  fi

  seen_dirs["$dir"]=1
  app_dirs+=("$dir")
}

auto_add_dir "${XDG_DATA_HOME:-$HOME/.local/share}/applications"

IFS=':' read -r -a xdg_data_dirs <<< "${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
for base_dir in "${xdg_data_dirs[@]}"; do
  auto_add_dir "$base_dir/applications"
done

declare -A app_entries=()

for app_dir in "${app_dirs[@]}"; do
  while IFS= read -r -d '' desktop_file; do
    app_id="$(basename "$desktop_file" .desktop)"
    [[ -n "$app_id" ]] || continue

    no_display="$(desktop_value "$desktop_file" "NoDisplay" || true)"
    hidden="$(desktop_value "$desktop_file" "Hidden" || true)"

    if is_true "$no_display" || is_true "$hidden"; then
      continue
    fi

    app_name="$(desktop_value "$desktop_file" "Name" || true)"
    [[ -n "$app_name" ]] || app_name="$app_id"

    if [[ -z "${app_entries[$app_id]+x}" ]]; then
      app_entries["$app_id"]="$app_name"
    fi
  done < <(find "$app_dir" -maxdepth 1 \( -type f -o -type l \) -name '*.desktop' -print0 2>/dev/null)
done

{
  for app_id in "${!app_entries[@]}"; do
    printf '%-35s %s\n' "$app_id" "${app_entries[$app_id]}"
  done
} | sort -f | {
  if [[ -n "$search_term" ]]; then
    grep -iF -- "$search_term" || true
  else
    cat
  fi
}
