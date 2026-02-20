# Vendored Dotfiles (`modules/nixos/home-manager/dotfiles`)

## Purpose

This subtree stores dotfiles that are deployed through Home Manager via `../dotfiles.nix`.

## How It Is Wired

- Source of truth mapping: `../dotfiles.nix`
- Runtime target: files are linked into `$HOME` (for example `~/.config/hypr`, `~/.config/waybar`, `~/.zshrc`, etc.)

## Directory Highlights

- `hypr/`: Hyprland compositor config and scripts
- `waybar/`: Waybar modules, style, and helper scripts
- `mako/`: notification daemon config
- `zsh/`, `nushell/`, `tmux/`, `wezterm/`, `ghostty/`: shell and terminal tooling
- `sotto/`: speech-to-text client config

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
