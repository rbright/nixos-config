# Shared Home Manager Assets

## Purpose

This subtree contains Home Manager assets reused by both hosts (`lambda` and `omega`).

## Files

- `dotfiles.nix`: shared `home.file` mapping consumed by OS-specific Home Manager modules.
- `dotfiles/`: shared dotfile source tree.

## Scope

- Put cross-OS dotfiles here.
- Keep NixOS-only files under `modules/nixos/home-manager/dotfiles/`.
- Keep macOS-only files under `modules/macos/dotfiles/`.

## WezTerm Shortcut Policy

- `SUPER+T` and `SUPER+W` are intentionally unbound so compositor shortcuts can own those chords.
- Tab creation is explicitly mapped to `CTRL+T`.
- Tab close stays on WezTerm's default `CTRL+SHIFT+W` binding.
