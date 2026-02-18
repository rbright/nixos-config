#!/usr/bin/env bash
set -euo pipefail

pass_count=0
fail_count=0
warn_count=0

ok() {
  pass_count=$((pass_count + 1))
  printf '[PASS] %s\n' "$1"
}

fail() {
  fail_count=$((fail_count + 1))
  printf '[FAIL] %s\n' "$1"
}

warn() {
  warn_count=$((warn_count + 1))
  printf '[WARN] %s\n' "$1"
}

require_cmd() {
  local cmd="$1"
  if command -v "$cmd" >/dev/null 2>&1; then
    ok "Command available: $cmd"
  else
    fail "Missing required command: $cmd"
  fi
}

check_workspace_rule() {
  local rules_json="$1"
  local workspace_name="$2"
  if jq -e --arg ws "$workspace_name" 'any(.[]; .workspaceString == $ws and .persistent == true)' \
    <<<"$rules_json" >/dev/null; then
    ok "Persistent workspace rule loaded: $workspace_name"
  else
    fail "Missing persistent workspace rule: $workspace_name"
  fi
}

check_exec_bind() {
  local binds_json="$1"
  local key="$2"
  local modmask="$3"
  local arg="$4"
  local label="$5"
  if jq -e \
    --arg key "$key" \
    --argjson modmask "$modmask" \
    --arg arg "$arg" \
    '
      any(.[]; .key == $key and .modmask == $modmask and .dispatcher == "exec" and .arg == $arg)
    ' <<<"$binds_json" >/dev/null; then
    ok "$label"
  else
    fail "$label"
  fi
}

check_bind() {
  local binds_json="$1"
  local key="$2"
  local modmask="$3"
  local dispatcher="$4"
  local arg="$5"
  local label="$6"
  if jq -e \
    --arg key "$key" \
    --argjson modmask "$modmask" \
    --arg dispatcher "$dispatcher" \
    --arg arg "$arg" \
    '
      any(
        .[];
        .key == $key
        and .modmask == $modmask
        and .dispatcher == $dispatcher
        and (((.arg // "") | gsub("\\s+"; "")) == ($arg | gsub("\\s+"; "")))
      )
    ' <<<"$binds_json" >/dev/null; then
    ok "$label"
  else
    fail "$label"
  fi
}

check_exec_bind_any_modmask() {
  local binds_json="$1"
  local key="$2"
  local arg="$3"
  local label="$4"
  if jq -e \
    --arg key "$key" \
    --arg arg "$arg" \
    '
      any(.[]; .key == $key and .dispatcher == "exec" and .arg == $arg)
    ' <<<"$binds_json" >/dev/null; then
    ok "$label"
  else
    fail "$label"
  fi
}

print_manual_checklist() {
  cat <<'EOF'

Manual E2E Checklist
1. Press Caps+B and confirm Brave is focused (or opens) on workspace `1`.
2. Press Caps+C and confirm Zed is focused (or opens) on workspace `2`.
3. Press Caps+M and confirm Messages app/webapp is focused (or opens) on workspace `7`.
4. Press Caps+Z and confirm WezTerm is focused (or opens) on workspace `10`.
5. Press Caps+Shift+B and confirm a new Brave window opens.
6. Press Caps+Shift+C and confirm a new Zed window opens.
7. Press Alt+1 then Alt+0 and confirm workspace switching works (`1` <-> `10`).
8. Press Alt+Shift+1 on an active window and confirm it moves to workspace `1`.
9. Press Super+H/J/K/L and confirm focus moves left/down/up/right.
10. Press Super+Shift+H/J/K/L and confirm active window moves left/down/up/right.
11. Press Super+[ and Super+] in Brave and Zed and confirm previous/next tab navigation.
12. Press Ctrl+Alt+Super+L and confirm Hyprlock opens.
13. Confirm both monitors always show `cat-waves-mocha.png`.

Useful runtime inspection commands:
- `hyprctl -j activewindow | jq '{class, title, workspace: .workspace.name}'`
- `hyprctl -j clients | jq '.[] | {class, title, workspace: .workspace.name}'`
EOF
}

main() {
  echo "Hyprland Runtime Smoke Test"

  require_cmd hyprctl
  require_cmd jq
  require_cmd hyprlock

  if (( fail_count > 0 )); then
    echo
    echo "Missing prerequisites. Aborting smoke test."
    exit 1
  fi

  local version_json
  if version_json="$(hyprctl -j version 2>/dev/null)"; then
    local version
    version="$(jq -r '.version // "unknown"' <<<"$version_json")"
    ok "Hyprland runtime reachable (version: $version)"
  else
    fail "Cannot reach a running Hyprland instance via hyprctl"
    echo
    echo "Run this command inside an active Hyprland session."
    exit 1
  fi

  local config_errors_json
  config_errors_json="$(hyprctl -j configerrors 2>/dev/null || echo '[]')"
  local non_empty_errors
  non_empty_errors="$(
    jq '
      [
        .[]
        | tostring
        | gsub("^\\s+|\\s+$"; "")
        | select(length > 0)
      ]
    ' <<<"$config_errors_json"
  )"
  if jq -e 'length == 0' <<<"$non_empty_errors" >/dev/null; then
    ok "No runtime config parse errors"
  else
    fail "Hyprland reports config errors"
    jq -r '.[]' <<<"$non_empty_errors" | sed 's/^/  - /'
  fi

  local kb_options
  kb_options="$(hyprctl -j getoption input:kb_options 2>/dev/null | jq -r '.str // ""')"
  if [[ "$kb_options" == *"caps:hyper"* ]]; then
    ok "Caps Lock remap active in runtime config (caps:hyper)"
  else
    fail "Caps Lock remap missing in runtime config (expected caps:hyper, got: $kb_options)"
  fi

  local runtime_dispatch="$HOME/.config/hypr/scripts/app-dispatch.sh"
  if [[ -x "$runtime_dispatch" ]]; then
    ok "Runtime app dispatcher is present and executable ($runtime_dispatch)"
  elif [[ -f "$runtime_dispatch" ]]; then
    fail "Runtime app dispatcher exists but is not executable ($runtime_dispatch)"
  else
    fail "Runtime app dispatcher missing ($runtime_dispatch)"
  fi

  local rules_json
  rules_json="$(hyprctl -j workspacerules 2>/dev/null || echo '[]')"
  for workspace_name in \
    "1" \
    "2" \
    "3" \
    "4" \
    "5" \
    "6" \
    "7" \
    "8" \
    "9" \
    "10"; do
    check_workspace_rule "$rules_json" "$workspace_name"
  done

  local binds_json
  binds_json="$(hyprctl -j binds 2>/dev/null || echo '[]')"

  # Mod masks in Hyprland:
  #   4 = CTRL, 8 = ALT, 9 = ALT+SHIFT, 32 = MOD3 (Hyper),
  #   33 = MOD3+SHIFT, 64 = SUPER, 65 = SUPER+SHIFT.
  local ctrl_modmask=4
  local alt_modmask=8
  local alt_shift_modmask=9
  local hyper_modmask=32
  local hyper_shift_modmask=33
  local super_modmask=64
  local super_shift_modmask=65

  check_exec_bind "$binds_json" "B" "$hyper_modmask" "sh ~/.config/hypr/scripts/app-dispatch.sh focus brave" "Hyper+B focus bind present"
  check_exec_bind "$binds_json" "C" "$hyper_modmask" "sh ~/.config/hypr/scripts/app-dispatch.sh focus zed" "Hyper+C focus bind present"
  check_exec_bind "$binds_json" "L" "$hyper_modmask" "sh ~/.config/hypr/scripts/app-dispatch.sh focus-only linear" "Hyper+L focus-only bind present"
  check_exec_bind "$binds_json" "M" "$hyper_modmask" "sh ~/.config/hypr/scripts/app-dispatch.sh focus messages" "Hyper+M focus bind present"
  check_exec_bind "$binds_json" "U" "$hyper_modmask" "sh ~/.config/hypr/scripts/app-dispatch.sh focus cider" "Hyper+U focus bind present"
  check_exec_bind "$binds_json" "Z" "$hyper_modmask" "sh ~/.config/hypr/scripts/app-dispatch.sh focus terminal" "Hyper+Z focus bind present"

  check_exec_bind "$binds_json" "B" "$hyper_shift_modmask" "sh ~/.config/hypr/scripts/app-dispatch.sh launch brave" "Hyper+Shift+B launch bind present"
  check_exec_bind "$binds_json" "C" "$hyper_shift_modmask" "sh ~/.config/hypr/scripts/app-dispatch.sh launch zed" "Hyper+Shift+C launch bind present"
  check_exec_bind "$binds_json" "L" "$hyper_shift_modmask" "sh ~/.config/hypr/scripts/app-dispatch.sh launch linear" "Hyper+Shift+L launch bind present"
  check_exec_bind "$binds_json" "M" "$hyper_shift_modmask" "sh ~/.config/hypr/scripts/app-dispatch.sh launch messages" "Hyper+Shift+M launch bind present"
  check_exec_bind "$binds_json" "U" "$hyper_shift_modmask" "sh ~/.config/hypr/scripts/app-dispatch.sh launch cider" "Hyper+Shift+U launch bind present"
  check_exec_bind "$binds_json" "Z" "$hyper_shift_modmask" "sh ~/.config/hypr/scripts/app-dispatch.sh launch terminal" "Hyper+Shift+Z launch bind present"

  check_bind "$binds_json" "1" "$alt_modmask" "workspace" "1" "Alt+1 workspace bind present"
  check_bind "$binds_json" "1" "$alt_shift_modmask" "movetoworkspace" "1" "Alt+Shift+1 move-to-workspace bind present"

  check_exec_bind "$binds_json" "SPACE" "$ctrl_modmask" "vicinae toggle" "Ctrl+Space launcher bind present"
  check_bind "$binds_json" "H" "$super_modmask" "movefocus" "l" "Super+H movefocus bind present"
  check_bind "$binds_json" "H" "$super_shift_modmask" "movewindow" "l" "Super+Shift+H movewindow bind present"
  check_bind "$binds_json" "BRACKETLEFT" "$super_modmask" "sendshortcut" "CTRL SHIFT,TAB" "Super+[ tab-left bind present"
  check_bind "$binds_json" "BRACKETRIGHT" "$super_modmask" "sendshortcut" "CTRL,TAB" "Super+] tab-right bind present"
  check_bind "$binds_json" "Q" "$super_modmask" "killactive" "" "Super+Q close-window bind present"
  check_exec_bind_any_modmask "$binds_json" "L" "hyprlock" "Ctrl+Alt+Super+L lock bind present"

  echo
  printf 'Summary: %s pass, %s warn, %s fail\n' "$pass_count" "$warn_count" "$fail_count"

  if (( fail_count == 0 )); then
    print_manual_checklist
    exit 0
  fi

  echo
  echo "Smoke test failed. Resolve failing checks, then rerun."
  exit 1
}

main "$@"
