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
