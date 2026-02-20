# Multi-Host Nix Configuration

This repository manages two host-specific Nix flakes:

| Host     | Platform                                               | Flake entrypoint         | Primary output                |
| -------- | ------------------------------------------------------ | ------------------------ | ----------------------------- |
| `lambda` | macOS (`nix-darwin` + `home-manager` + `nix-homebrew`) | `hosts/lambda/flake.nix` | `darwinConfigurations.lambda` |
| `omega`  | NixOS (`nixosSystem` + `home-manager`)                 | `hosts/omega/flake.nix`  | `nixosConfigurations.omega`   |

## Quick Start

### Prerequisites

- Nix with flakes enabled (`nix --version`)
- [`just`](https://github.com/casey/just) (`just --version`)
- Git checkout of this repository

### First successful run (Linux/NixOS environment)

```sh
just --list
just lint
just build omega
```

Success looks like:

- `just --list` prints `bootstrap`, `nix`, and `qa` recipe groups.
- `just lint` exits `0`.
- `just build omega` exits `0`.

### First successful run on macOS (`lambda`)

```sh
just bootstrap lambda
just build lambda
just switch lambda
```

Success looks like:

- Bootstrap completes Xcode CLI + Nix installer flow.
- `build`/`switch` complete without evaluation errors.

> [!NOTE]
> `just build lambda` requires a Darwin builder (`aarch64-darwin`) and is expected to fail on Linux-only systems.

## Root Command Surface (`just`)

Run `just --list` for the authoritative command list.

| Workflow                              | Command                                       |
| ------------------------------------- | --------------------------------------------- |
| Bootstrap local machine               | `just bootstrap <lambda / omega>`             |
| Build config                          | `just build <lambda / omega>`                 |
| Activate config                       | `just switch <lambda / omega>`                |
| Install alias                         | `just install <lambda / omega>`               |
| Update host lock file                 | `just update <lambda / omega>`                |
| Update one flake input                | `just update-flake <input> <lambda / omega>`  |
| List generations                      | `just list <lambda / omega>`                  |
| Roll back generation                  | `just rollback <lambda / omega> <generation>` |
| Clean old generations                 | `just clean <lambda / omega> [older_than]`    |
| Format Nix files                      | `just fmt`                                    |
| Check formatting only                 | `just fmt-check`                              |
| Lint Nix files                        | `just lint`                                   |
| Hyprland runtime smoke test (`omega`) | `just hypr-smoke`                             |

For command semantics, arguments, and expected results, see [`docs/commands.md`](docs/commands.md).

## Documentation Map

### Audience-based start points

| Need                               | Start here                                 | Then go to                                                                             |
| ---------------------------------- | ------------------------------------------ | -------------------------------------------------------------------------------------- |
| First setup / first successful run | [Quick Start](#quick-start)                | [`docs/commands.md`](docs/commands.md), [`docs/architecture.md`](docs/architecture.md) |
| Daily workflow                     | [`docs/commands.md`](docs/commands.md)     | [`docs/validation.md`](docs/validation.md), host/module docs                           |
| CI failure triage                  | [`docs/validation.md`](docs/validation.md) | [`docs/troubleshooting.md`](docs/troubleshooting.md)                                   |
| Runtime host operations            | [`hosts/README.md`](hosts/README.md)       | Host-specific + module-specific runbooks                                               |

### Core docs

- **Architecture:** [`docs/architecture.md`](docs/architecture.md)
- **Commands & workflows:** [`docs/commands.md`](docs/commands.md)
- **Validation and CI parity:** [`docs/validation.md`](docs/validation.md)
- **Troubleshooting:** [`docs/troubleshooting.md`](docs/troubleshooting.md)

### Authoritative vs. derived sources

| Topic                  | Authoritative source                 | Derived docs                                                                   |
| ---------------------- | ------------------------------------ | ------------------------------------------------------------------------------ |
| Command surface        | [`justfile`](justfile)               | [`README.md`](README.md), [`docs/commands.md`](docs/commands.md)               |
| Host assembly          | `hosts/*/flake.nix`, `hosts/*/*.nix` | [`hosts/README.md`](hosts/README.md)                                           |
| Shared policy          | `modules/shared/*.nix`               | [`modules/shared/README.md`](modules/shared/README.md)                         |
| macOS config           | `modules/macos/*.nix`                | [`modules/macos/README.md`](modules/macos/README.md)                           |
| NixOS config           | `modules/nixos/*.nix`                | [`modules/nixos/README.md`](modules/nixos/README.md)                           |
| Home Manager (`omega`) | `modules/nixos/home-manager/*.nix`   | [`modules/nixos/home-manager/README.md`](modules/nixos/home-manager/README.md) |

### Configuration-area docs

- **Hosts:** [`hosts/README.md`](hosts/README.md)
  - [`hosts/lambda/README.md`](hosts/lambda/README.md)
  - [`hosts/omega/README.md`](hosts/omega/README.md)
- **Modules:** [`modules/README.md`](modules/README.md)
  - [`modules/shared/README.md`](modules/shared/README.md)
  - [`modules/macos/README.md`](modules/macos/README.md)
  - [`modules/nixos/README.md`](modules/nixos/README.md)
  - [`modules/nixos/home-manager/README.md`](modules/nixos/home-manager/README.md)
  - [`modules/nixos/programs/README.md`](modules/nixos/programs/README.md)

## Notes on Portability

Examples in documentation use placeholders like `<host>`, `<bucket-name>`, `<project-id>`, and `<repo-root>` so docs can be reused across machines and environments.
