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

active_class="$(
  hyprctl -j activewindow 2>/dev/null \
    | jq -r '(.class // "") | ascii_downcase' 2>/dev/null \
    || true
)"

is_terminal=0
case "$active_class" in
  *ghostty* | *wezterm* | *kitty* | *alacritty* | *foot* | *terminal*)
    is_terminal=1
    ;;
esac

if [ "$action" = "copy" ]; then
  if [ "$is_terminal" -eq 1 ]; then
    hyprctl --quiet dispatch sendshortcut "CTRL SHIFT, C" >/dev/null 2>&1 || true
  else
    hyprctl --quiet dispatch sendshortcut "CTRL, C" >/dev/null 2>&1 || true
  fi
  exit 0
fi

if [ "$is_terminal" -eq 1 ]; then
  hyprctl --quiet dispatch sendshortcut "CTRL SHIFT, V" >/dev/null 2>&1 || true
else
  hyprctl --quiet dispatch sendshortcut "CTRL, V" >/dev/null 2>&1 || true
fi
