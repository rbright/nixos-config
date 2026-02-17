#!/usr/bin/env sh
set -eu

usage() {
  echo "Usage: $0 <copy|paste>" >&2
  exit 2
}

action="${1:-}"
[ -n "$action" ] || usage

case "$action" in
  copy | paste) ;;
  *)
    usage
    ;;
esac

read_active_window_meta() {
  # Print "<class> <address>" where address is in "0x..." format.
  hyprctl activewindow 2>/dev/null \
    | awk '
        BEGIN {
          address = ""
          class = ""
          initial_class = ""
        }
        /^Window / {
          address = "0x" $2
        }
        /^[[:space:]]*class:[[:space:]]*/ {
          line = $0
          sub(/^[[:space:]]*class:[[:space:]]*/, "", line)
          class = tolower(line)
        }
        /^[[:space:]]*initialClass:[[:space:]]*/ {
          line = $0
          sub(/^[[:space:]]*initialClass:[[:space:]]*/, "", line)
          initial_class = tolower(line)
        }
        END {
          if (class == "") {
            class = initial_class
          }
          if (class != "" && address != "") {
            print class " " address
          }
        }
      '
}

active_class=""
active_addr=""
attempt=0
while [ "$attempt" -lt 5 ]; do
  meta="$(read_active_window_meta || true)"
  if [ -n "$meta" ]; then
    active_class="${meta%% *}"
    active_addr="${meta##* }"
    if [ -n "$active_class" ] && [ -n "$active_addr" ]; then
      break
    fi
  fi
  attempt=$((attempt + 1))
  sleep 0.01
done

# Fail closed if active window metadata cannot be resolved. This prevents
# accidental delivery of CTRL+C to an unintended target.
[ -n "$active_class" ] && [ -n "$active_addr" ] || exit 1

is_terminal=0
case "$active_class" in
  *ghostty* | *wezterm* | *kitty* | *alacritty* | *foot* | *xterm* | *terminal*)
    is_terminal=1
    ;;
esac

# Zed with vim_mode enabled can treat CTRL+C/V differently; use explicit
# SUPER bindings in Zed instead.
is_zed=0
case "$active_class" in
  *dev.zed.zed* | *zed*)
    is_zed=1
    ;;
esac

if [ "$is_zed" -eq 1 ]; then
  if [ "$action" = "copy" ]; then
    hyprctl --quiet dispatch sendshortcut "SUPER,C,address:$active_addr" >/dev/null 2>&1 || true
  else
    hyprctl --quiet dispatch sendshortcut "SUPER,V,address:$active_addr" >/dev/null 2>&1 || true
  fi
  exit 0
fi

if [ "$action" = "copy" ]; then
  if [ "$is_terminal" -eq 1 ]; then
    hyprctl --quiet dispatch sendshortcut "CTRL SHIFT,C,address:$active_addr" >/dev/null 2>&1 || true
  else
    hyprctl --quiet dispatch sendshortcut "CTRL,C,address:$active_addr" >/dev/null 2>&1 || true
  fi
  exit 0
fi

if [ "$is_terminal" -eq 1 ]; then
  hyprctl --quiet dispatch sendshortcut "CTRL SHIFT,V,address:$active_addr" >/dev/null 2>&1 || true
else
  hyprctl --quiet dispatch sendshortcut "CTRL,V,address:$active_addr" >/dev/null 2>&1 || true
fi
