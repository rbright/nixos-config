#!/usr/bin/env sh
set -eu

usage() {
  echo "Usage: $0 <focus|launch> <app-key>" >&2
  exit 2
}

mode="${1:-}"
app="${2:-}"

[ -n "$mode" ] || usage
[ -n "$app" ] || usage

class_regex=""
title_regex=""
launch_cmd=""
target_workspace=""

case "$app" in
  brave)
    class_regex='^(brave-browser|Brave-browser)$'
    launch_cmd='brave-personal --new-window'
    target_workspace='1'
    ;;
  calendar)
    class_regex='^(org\.gnome\.Calendar|gnome-calendar|brave-browser|Brave-browser|brave-.*)$'
    title_regex='calendar'
    launch_cmd='brave-work --new-window --app=https://calendar.google.com'
    target_workspace='8'
    ;;
  sunsama)
    class_regex='^(sunsama|Sunsama|brave-browser|Brave-browser|brave-.*)$'
    title_regex='sunsama'
    launch_cmd='sunsama || brave-work --new-window --app=https://app.sunsama.com'
    target_workspace='5'
    ;;
  todoist)
    class_regex='^(todoist|Todoist|brave-browser|Brave-browser|brave-.*)$'
    title_regex='todoist'
    launch_cmd='todoist || brave-work --new-window --app=https://app.todoist.com'
    target_workspace='5'
    ;;
  linear)
    class_regex='^(linear|Linear|brave-browser|Brave-browser|brave-.*)$'
    title_regex='linear'
    launch_cmd='linear || brave-work --new-window --app=https://linear.app'
    target_workspace='5'
    ;;
  obsidian)
    class_regex='^(obsidian|Obsidian|md\.obsidian)$'
    launch_cmd='obsidian'
    target_workspace='4'
    ;;
  messages)
    class_regex='^(messages|Messages|brave-browser|Brave-browser|brave-.*)$'
    title_regex='messages'
    launch_cmd='brave-work --new-window --app=https://messages.google.com/web/conversations'
    target_workspace='7'
    ;;
  mimestream)
    class_regex='^(mimestream|Mimestream|thunderbird|Thunderbird|brave-browser|Brave-browser|brave-.*)$'
    title_regex='mimestream|gmail|mail'
    launch_cmd='mimestream || thunderbird || brave-work --new-window --app=https://mail.google.com'
    target_workspace='7'
    ;;
  slack)
    class_regex='^(Slack|slack)$'
    launch_cmd='slack'
    target_workspace='7'
    ;;
  discord)
    class_regex='^(Discord|discord)$'
    launch_cmd='discord'
    target_workspace='7'
    ;;
  terminal)
    class_regex='^(org\.wezfurlong\.wezterm|WezTerm|wezterm)$'
    launch_cmd='wezterm'
    target_workspace='10'
    ;;
  agent-monitor)
    class_regex='^(codexmonitor|CodexMonitor|conductor|Conductor|brave-browser|Brave-browser|brave-.*)$'
    title_regex='codex|openai|usage|monitor|conductor'
    launch_cmd='codex monitor || brave-work --new-window --app=https://platform.openai.com/usage'
    target_workspace='9'
    ;;
  zed)
    class_regex='^(dev\.zed\.Zed|Zed|zed)$'
    launch_cmd='zeditor || zed'
    target_workspace='2'
    ;;
  vscode)
    class_regex='^(com\.microsoft\.VSCode|Code|code)$'
    launch_cmd='code --new-window'
    target_workspace='9'
    ;;
  tableplus)
    class_regex='^(TablePlus|tableplus|Postman|postman)$'
    launch_cmd='tableplus || postman'
    target_workspace='3'
    ;;
  *)
    echo "Unknown app key: $app" >&2
    exit 2
    ;;
esac

launch_app() {
  if [ -n "$target_workspace" ]; then
    hyprctl dispatch workspace "$target_workspace" >/dev/null 2>&1 || true
  fi

  # shellcheck disable=SC2091
  (sh -c "$launch_cmd") >/dev/null 2>&1 &
}

focus_existing() {
  client="$(
    hyprctl -j clients \
      | jq -re \
        --arg class "$class_regex" \
        --arg title "$title_regex" \
        '
          [
            .[]
            | select(
                ((.class // "") | test($class; "i"))
                and (
                  if $title == "" then
                    true
                  else
                    ((.title // "") | test($title; "i"))
                  end
                )
              )
            | {
                address: (.address // ""),
                workspace_id: (.workspace.id // 0),
                focus_history: (.focusHistoryID // 999999)
              }
          ]
          | sort_by(.focus_history)
          | .[0]
        '
  )" || return 1

  address="$(printf '%s' "$client" | jq -r '.address')"
  workspace_id="$(printf '%s' "$client" | jq -r '.workspace_id')"

  [ -n "$address" ] || return 1
  [ "$address" != "null" ] || return 1

  hyprctl dispatch workspace "$workspace_id" >/dev/null 2>&1 || true
  hyprctl dispatch focuswindow "address:$address" >/dev/null 2>&1
}

case "$mode" in
  focus)
    focus_existing || launch_app
    ;;
  launch)
    launch_app
    ;;
  *)
    usage
    ;;
esac
