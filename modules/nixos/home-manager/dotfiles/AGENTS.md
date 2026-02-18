# Dotfiles Subtree Agent Guide

## Scope

These rules apply only under `modules/nixos/home-manager/dotfiles/`.

## Mission

Keep interactive shell/desktop dotfiles deterministic, syntax-safe, and runtime-validated.

## Workflow Rules

| Scope | Problem | Rule | Why | Example | When to use | Benefits |
| --- | --- | --- | --- | --- | --- | --- |
| Component | Runtime keybind/window-manager regressions | For Hyprland-impacting changes (`hypr/`, `waybar/`, `mako/`), run `just hypr-smoke` from an active Hyprland session. | Lint/build do not validate live keybinds, workspace rules, or runtime config errors. | `just hypr-smoke` | Any edit under `hypr/`, `waybar/`, or `mako/` | Catches runtime breakage before deployment |
| Component | Silent shell-script parse failures | Run native syntax checks for changed script files. | Dotfile scripts are executed at runtime and can fail after switch if unchecked. | `bash -n path/to/script.sh`, `zsh -n path/to/file.zsh`, `nu --ide-check 50 path/to/config.nu` | Changes to shell scripts/configs | Faster feedback and safer switches |
| Component | Broken runtime wiring | Keep launcher/helper scripts executable and referenced by explicit runtime paths under `~/.config/...`. | Non-executable or mismatched paths break keybind dispatch at runtime. | Ensure `~/.config/hypr/scripts/*.sh` remains executable. | Changes to script references in Hypr/Waybar/Mako configs | Reliable runtime dispatch behavior |
| Component | Behavior changes not discoverable later | Update `README.md` when changing user-facing shortcuts, launcher targets, or desktop defaults. | Desktop behavior is operationally critical and frequently consulted from docs. | Add/adjust shortcut docs in README Hyprland section. | Any user-visible desktop behavior change | Prevents stale operational guidance |

## Validation Baseline

- `just lint`
- `just build omega`
- `just hypr-smoke` (for Hyprland-impacting changes)

If Hyprland runtime is unavailable, record the skip and include the exact command to run later.
