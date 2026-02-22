# Vendored Dotfiles (`modules/nixos/home-manager/dotfiles`)

## Purpose

This subtree stores NixOS-only dotfiles deployed through Home Manager via `../dotfiles.nix`.

## How It Is Wired

- Source of truth mapping: `../dotfiles.nix`
- Runtime target: files are linked into `$HOME` (for example `~/.config/hypr`, `~/.config/waybar`, etc.)

## Directory Highlights

- `hypr/`: Hyprland compositor config and scripts
- `waybar/`: Waybar modules, style, and helper scripts
- `mako/`: notification daemon config
- `sotto/`: speech-to-text client config

Shared shell/terminal dotfiles now live under `modules/shared/home-manager/dotfiles/`.

## Waybar: Linear notifications + GitHub pull-requests menus

Waybar includes two dropdown modules inspired by Raycast menu-bar commands.

Implementation source of truth now lives in standalone Go repos:

- `/home/rbright/Projects/waybar-modules/waybar-linear` (`waybar-linear` binary)
- `/home/rbright/Projects/waybar-modules/waybar-github` (`waybar-github` binary)

Waybar modules:

- `custom/linear-notifications` (unread Linear notifications)
- `custom/github-pull-requests` (open GitHub pull requests involving you)

Behavior:

- Click icon to open a dropdown menu with individual items
- Click an item in the dropdown to open it in the browser
- Linear menu includes `Mark All as Read`

Optional runtime config files (not committed):

- `~/.config/waybar/linear-notifications.env`
  - `LINEAR_API_KEY=<linear-personal-api-key>`
  - `MAX_ITEMS=<menu-item-count>` (optional, default `8`, max `12`)
- `~/.config/waybar/github-pull-requests.env`
  - `GITHUB_TOKEN=<github-token>` (optional)
  - `PR_QUERY=<github-search-query>` (optional; default `is:open is:pr involves:@me archived:false sort:updated-desc`)
  - `MAX_ITEMS=<menu-item-count>` (optional, default `8`, max `12`)

Preferred GitHub auth path is OAuth/device login via:

```sh
gh auth login
gh auth status -h github.com
```

After editing Waybar files, apply with `just switch omega`.

## Hyprland Shortcut Notes

- `Hyper+B`: focus personal Brave (`Hyper+Shift+B` launches a new personal window).
- `Hyper+V`: focus work Brave profile (`Hyper+Shift+V` launches a new work window).
- `Hyper+R`: focus VS Code (`Hyper+Shift+R` launches a new window).
- `Ctrl+Alt+Super+V`: compact multiline clipboard commands to one line, then paste.
- `Alt+Super+C`: open Vicinae clipboard history.
- `Super+T`: open Vicinae Todoist "Create Task" command.

Trim helper script usage:

```sh
sh ~/.config/hypr/scripts/trim-multiline-command.sh [compact|paste|print]
```

## Editing Workflow

1. Edit files under this subtree.
2. Apply config:

```sh
just switch omega
```

3. If change impacts Hyprland/Waybar/Mako runtime behavior, run:

```sh
just hypr-smoke
```

4. Validate Hyprland runtime parse status:

```sh
hyprctl -j configerrors | jq .
```

## Notes

- Keep machine-specific secrets/tokens out of this subtree.
- Prefer placeholders in documentation/examples (`<project-id>`, `<bucket-name>`, `<mount-dir>`).
