# Nix Configuration for `lambda` and `omega`

This repository manages two hosts with a shared module baseline:

- `lambda`: macOS (`nix-darwin` + `home-manager` + `nix-homebrew`)
- `omega`: Ubuntu (`home-manager`, not NixOS)

The goal is to share as much as possible while keeping platform-specific concerns isolated.

## Architecture

- Shared Nix settings: `modules/default.nix`
- Shared package baseline: `modules/packages.nix`
- macOS-only modules: `modules/darwin/`
- Host entrypoints:
- `hosts/lambda/default.nix`
- `hosts/omega/default.nix`
- Flake outputs:
- `darwinConfigurations.lambda`
- `homeConfigurations.omega`

## Host Matrix

| Host | OS | Flake Output | Switch Method |
|------|----|--------------|---------------|
| `lambda` | macOS (aarch64-darwin) | `darwinConfigurations.lambda` | `darwin-rebuild switch --flake .#lambda` |
| `omega` | Ubuntu (x86_64-linux) | `homeConfigurations.omega` | Home Manager activation package |

## Getting Started

### 1. Install Nix

- `lambda`:
  - `just bootstrap lambda`
- `omega`:
  - `just bootstrap omega`

### 2. Build Host Configuration

- `lambda`:
  - `just build lambda`
- `omega`:
  - `just build omega`

### 3. Activate Host Configuration

- `lambda`:
  - `just switch lambda`
- `omega`:
  - `just switch omega`

## Command Reference

Run `just --list` for the full task inventory.

### Nix / Host Operations

- Build host config:
  - `just build lambda`
  - `just build omega`
- Switch host config:
  - `just switch lambda`
  - `just switch omega`
- Install (alias of `switch`):
  - `just install lambda`
  - `just install omega`
- List generations:
  - `just list lambda`
  - `just list omega`
- Roll back:
  - `just rollback lambda <generation-number>`
  - `just rollback omega <activation-path>`

### Maintenance

- Update all flake inputs:
  - `just update`
- Update one flake input:
  - `just update-flake nixpkgs`
- Format Nix files:
  - `just fmt`
- Lint Nix files:
  - `just lint`

## Customization

### Shared Packages

Edit `modules/packages.nix` for packages intended for both hosts.

Platform-specific entries are gated in that file (for example, Darwin-only tools).

### macOS-Specific Settings (`lambda`)

- System preferences and app defaults: `modules/darwin/`
- Homebrew taps/casks/brews: `modules/darwin/homebrew/`

### Ubuntu-Specific Settings (`omega`)

- Home Manager host module: `hosts/omega/default.nix`
- Add Ubuntu-only settings directly there or split into `modules/linux/` as it grows.

## Deployment Strategy

This repo now uses host-aware `just` commands as the deployment interface instead of legacy `apps/aarch64-darwin/*` wrappers.

That keeps the operational path explicit and consistent:

- local build/switch for `lambda`
- local Home Manager activation for `omega`

## Directory Structure

```sh
nixos-config/
├── flake.nix
├── flake.lock
├── justfile
├── scripts/
│   └── bootstrap.zsh
├── hosts/
│   ├── lambda/
│   │   └── default.nix
│   └── omega/
│       └── default.nix
└── modules/
    ├── default.nix
    ├── packages.nix
    └── darwin/
        ├── default.nix
        └── ...
```
