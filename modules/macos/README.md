# macOS Modules (`modules/macos`)

## Purpose

This directory contains `nix-darwin` modules consumed by `hosts/lambda/flake.nix`.

## Structure

- `default.nix`: imports the macOS module set.
- `applications/`: app-level defaults and system app behavior.
- `dock/`: dock defaults and declarative entries.
- `homebrew/`: brew/cask/tap/MAS declarations.
- `home-manager.nix`: Home Manager wiring for the macOS user.
- `packages.nix`: macOS-specific user packages.
- Remaining `*.nix`: focused system preferences (keyboard, finder, security, networking, etc.).

## Common Changes

- Add/remove Homebrew packages: `homebrew/brews.nix`, `homebrew/casks.nix`
- Change Dock items: `dock/entries/default.nix`
- Add macOS-only packages: `packages.nix`
- Adjust user-level files managed by Home Manager: `files.nix`

## Verification

```sh
just lint
just build lambda
just switch lambda
```

Success looks like: build and switch complete without evaluation errors.

> `just build lambda` requires a Darwin builder.
