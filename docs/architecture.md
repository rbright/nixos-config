# Architecture Overview

## System Topology

This repository keeps macOS and NixOS configuration isolated by host while sharing common policy modules.

```text
hosts/
├── lambda/  (macOS flake)
└── omega/   (NixOS flake)

modules/
├── shared/  (cross-host policy)
├── macos/   (nix-darwin modules)
└── nixos/   (NixOS + Home Manager modules)
```

Each host has its own `flake.nix` and `flake.lock` so dependency updates can be host-scoped.

## Composition Model

### `lambda` (macOS)

`hosts/lambda/flake.nix` assembles:

1. `home-manager.darwinModules.home-manager`
2. `nix-homebrew.darwinModules.nix-homebrew`
3. shared policy from `modules/shared/`
4. macOS modules from `modules/macos/`
5. host-local wiring from `hosts/lambda/default.nix`

### `omega` (NixOS)

`hosts/omega/flake.nix` assembles:

1. `home-manager.nixosModules.home-manager`
2. host overlays/packages (for host-specific tooling)
3. shared policy from `modules/shared/`
4. NixOS modules from `modules/nixos/`
5. optional local/service modules declared as flake inputs
6. host-local wiring from `hosts/omega/default.nix`

## Source-of-Truth Map

| Concern                      | Source of truth                  |
| ---------------------------- | -------------------------------- |
| Command behavior             | `justfile`                       |
| macOS host output            | `hosts/lambda/flake.nix`         |
| NixOS host output            | `hosts/omega/flake.nix`          |
| Shared package/tool baseline | `modules/shared/packages.nix`    |
| macOS system behavior        | `modules/macos/`                 |
| NixOS system behavior        | `modules/nixos/`                 |
| Omega Home Manager wiring    | `modules/nixos/home-manager.nix` |
| Omega program modules        | `modules/nixos/programs/`        |

## Local Path Inputs

Some `omega` inputs may point at local clones (for example, local development of supporting flakes). Keep these paths machine-specific in code, but document them using placeholders:

- `path:/<absolute-path-to-local-flake>`

When onboarding a new machine, update those paths in `hosts/omega/flake.nix` to match local checkout locations.

## Where to Go Next

- Command reference: [`commands.md`](commands.md)
- Validation loop: [`validation.md`](validation.md)
- Host guides: [`../hosts/README.md`](../hosts/README.md)
- Module guides: [`../modules/README.md`](../modules/README.md)
