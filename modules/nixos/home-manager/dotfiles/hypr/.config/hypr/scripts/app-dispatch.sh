#!/usr/bin/env sh
set -eu

usage() {
  echo "Usage: $0 <focus|focus-only|launch> <app-key>" >&2
  exit 2
}

mode="${1:-}"
app="${2:-}"

[ -n "$mode" ] || usage
[ -n "$app" ] || usage

class_regex=""
title_regex=""
cmdline_regex=""
launch_cmd=""
target_workspace=""

case "$app" in
  brave)
    class_regex='^(brave-browser|Brave-browser)$'
    cmdline_regex='--profile-directory=Default'
    launch_cmd='brave-personal --new-window'
    target_workspace='1'
    ;;
  brave-work)
    class_regex='^(brave-browser|Brave-browser)$'
    cmdline_regex='--profile-directory=Profile 1'
    launch_cmd='brave-work --new-window'
    target_workspace='1'
    ;;
  calendar)
    class_regex='^(org\.gnome\.Calendar|gnome-calendar|calendar|Calendar)$'
    launch_cmd='gnome-calendar'
    target_workspace='8'
    ;;
  cider)
    class_regex='^(cider|Cider|cider-2|cider2|com\.ciderapp\.Cider)$'
    launch_cmd='cider-2 || cider'
    ;;
  discord)
    class_regex='^(Discord|discord)$'
    launch_cmd='discord'
    target_workspace='7'
    ;;
  email)
    class_regex='^(thunderbird|Thunderbird|brave-browser|Brave-browser|brave-.*)$'
    title_regex='gmail|mail'
    launch_cmd='thunderbird || brave-work --new-window --app=https://mail.google.com'
    target_workspace='7'
    ;;
  linear)
    class_regex='^(linear|Linear|brave-browser|Brave-browser|brave-.*)$'
    title_regex='linear'
    launch_cmd='linear || brave-work --new-window --app=https://linear.app'
    target_workspace='5'
    ;;
  messages)
    class_regex='^(messages|Messages|brave-browser|Brave-browser|brave-.*)$'
    title_regex='messages'
    launch_cmd='brave-work --new-window --app=https://messages.google.com/web/conversations'
    target_workspace='7'
    ;;
  obsidian)
    class_regex='^(obsidian|Obsidian|md\.obsidian)$'
    launch_cmd='obsidian'
    target_workspace='4'
    ;;
  sunsama)
    class_regex='^(sunsama|Sunsama|brave-browser|Brave-browser|brave-.*)$'
    title_regex='sunsama'
    launch_cmd='sunsama || brave-work --new-window --app=https://app.sunsama.com'
    target_workspace='5'
    ;;
  slack)
    class_regex='^(Slack|slack)$'
    launch_cmd='env GTK_THEME=catppuccin-mocha-blue-standard:dark GTK_APPLICATION_PREFER_DARK_THEME=1 slack'
    target_workspace='7'
    ;;
  datagrip)
    class_regex='^(jetbrains-datagrip|datagrip|DataGrip)$'
    launch_cmd='datagrip'
    target_workspace='3'
    ;;
  terminal)
    class_regex='^(org\.wezfurlong\.wezterm|WezTerm|wezterm)$'
    launch_cmd='wezterm'
    target_workspace='10'
    ;;
  todoist)
    class_regex='^(todoist|Todoist|brave-browser|Brave-browser|brave-.*)$'
    title_regex='todoist'
    launch_cmd='todoist || brave-work --new-window --app=https://app.todoist.com'
    target_workspace='5'
    ;;
  vscode)
    class_regex='^(com\.microsoft\.VSCode|Code|code)$'
    launch_cmd='code --new-window'
    target_workspace='2'
    ;;
  zed)
    class_regex='^(dev\.zed\.Zed|Zed|zed)$'
    launch_cmd='zeditor || zed'
    target_workspace='2'
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
  clients="$(
    hyprctl -j clients \
      | jq -ce \
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
                focus_history: (.focusHistoryID // 999999),
                pid: (.pid // null)
              }
          ]
          | sort_by(.focus_history)
        '
  )" || return 1

  if [ -n "$cmdline_regex" ]; then
    client="$(
      printf '%s' "$clients" \
        | jq -c '.[]' \
        | while IFS= read -r candidate; do
            pid="$(printf '%s' "$candidate" | jq -r '.pid')"
            [ -n "$pid" ] || continue
            [ "$pid" != "null" ] || continue

            cmdline="$(tr '\0' ' ' < "/proc/$pid/cmdline" 2>/dev/null || true)"
            printf '%s' "$cmdline" | grep -Eiq -- "$cmdline_regex" || continue

            printf '%s\n' "$candidate"
            break
          done
    )"
  else
    client="$(printf '%s' "$clients" | jq -ce '.[0]' 2>/dev/null || true)"
  fi

  [ -n "$client" ] || return 1
  [ "$client" != "null" ] || return 1

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
  focus-only)
    focus_existing || true
    ;;
  launch)
    launch_app
    ;;
  *)
    usage
    ;;
esac
