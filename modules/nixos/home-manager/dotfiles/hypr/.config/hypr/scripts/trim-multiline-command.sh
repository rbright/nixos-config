#!/usr/bin/env sh
set -eu

usage() {
  echo "Usage: $0 [compact|paste|print]" >&2
  exit 2
}

action="${1:-compact}"
case "$action" in
  compact | paste | print) ;;
  *)
    usage
    ;;
esac

read_clipboard() {
  wl-paste --type text 2>/dev/null || wl-paste 2>/dev/null || true
}

compact_command() {
  awk '
    function trim(s) {
      sub(/^[[:space:]]+/, "", s)
      sub(/[[:space:]]+$/, "", s)
      return s
    }

    function strip_prompt(s) {
      if (s ~ /^\$[[:space:]]+/) {
        sub(/^\$[[:space:]]+/, "", s)
      } else if (s ~ /^#[[:space:]]+/) {
        sub(/^#[[:space:]]+/, "", s)
      } else if (s ~ /^>[[:space:]]+/) {
        sub(/^>[[:space:]]+/, "", s)
      }
      return s
    }

    {
      line = $0
      gsub(/\r/, "", line)
      line = trim(line)
      if (line == "" || line ~ /^```/) {
        next
      }

      line = strip_prompt(line)

      # Remove a single trailing continuation backslash (odd count only).
      if (line ~ /(^|[^\\])(\\\\)*\\$/) {
        sub(/[[:space:]]*\\$/, "", line)
      }

      line = trim(line)
      if (line == "") {
        next
      }

      if (out == "") {
        out = line
      } else {
        out = out " " line
      }
    }

    END {
      printf "%s", out
    }
  '
}

raw="$(read_clipboard)"
[ -n "$raw" ] || exit 0

compacted="$(printf '%s\n' "$raw" | compact_command)"
[ -n "$compacted" ] || exit 0

case "$action" in
  print)
    printf '%s\n' "$compacted"
    ;;
  compact)
    printf '%s' "$compacted" | wl-copy
    ;;
  paste)
    printf '%s' "$compacted" | wl-copy
    sh ~/.config/hypr/scripts/macos-copy-paste.sh paste
    ;;
esac
