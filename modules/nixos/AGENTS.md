# NixOS Modules Agent Guide

## Scope

These rules apply to `modules/nixos/` (including `home-manager/` and `programs/`).

## Mission

Keep NixOS + Home Manager behavior deterministic, host-safe, and reviewable.

## Workflow Rules

| Scope | Problem | Rule | Why | Example | When to use | Benefits |
| --- | --- | --- | --- | --- | --- | --- |
| Module | New GUI apps not routed to intended Hyprland workspace | When adding/removing GUI packages in `modules/nixos/packages.nix`, update `modules/nixos/home-manager/dotfiles/hypr/.config/hypr/windowrules.conf` in the same change when workspace pinning is expected. | Package additions without matching window rules cause apps to open on inconsistent workspaces. | Add `libreoffice` package + add/adjust `ws3-*` rule for `libreoffice-*` classes. | Any desktop app package change for `omega` | Predictable app placement and fewer runtime surprises |
| Module | Ambiguous ownership of desktop behavior | Keep package declaration in `packages.nix` and workspace placement in Hypr dotfiles; avoid host-level one-off shell hacks. | Preserves declarative behavior across rebuilds and rollbacks. | Configure app install in `packages.nix`, class/title routing in `windowrules.conf`. | Any app install + workspace routing change | Clear source of truth |

## Validation Baseline

- `just lint`
- `just build omega`
- If Hyprland files changed: `just hypr-smoke`

If Hyprland runtime is unavailable, explicitly report the skip and include the exact command to run later.
