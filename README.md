# Multi-Host Nix Configuration

This repository manages two hosts:

- `lambda`: macOS (`nix-darwin` + `home-manager` + `nix-homebrew`)
- `omega`: NixOS (`nixosSystem` + `home-manager`)

## Architecture

Each host owns its own flake and lock file:

- macOS host flake: `hosts/lambda/flake.nix`, `hosts/lambda/flake.lock`
- NixOS host flake: `hosts/omega/flake.nix`, `hosts/omega/flake.lock`

OS policy remains reusable under modules:

- Shared macOS modules: `modules/macos/`
- Shared NixOS modules: `modules/nixos/`
  - Program modules split under `modules/nixos/programs/`
- Shared baseline modules: `modules/shared/default.nix`, `modules/shared/packages.nix`
- Host entrypoints:
  - `hosts/lambda/default.nix`
  - `hosts/omega/default.nix`
  - `hosts/omega/bluetooth.nix`
  - `hosts/omega/boot.nix`
  - `hosts/omega/configuration.nix`
  - `hosts/omega/hardware-configuration.nix`
  - `hosts/omega/video.nix`

Host outputs (no root flake composition):

- `path:.?dir=hosts/lambda#darwinConfigurations.lambda`
- `path:.?dir=hosts/omega#nixosConfigurations.omega`

## Host Commands

Run `just --list` for the full command catalog.

| Operation | Lambda (macOS) | Omega (NixOS) |
|---|---|---|
| Build | `just build lambda` | `just build omega` |
| Install / Switch | `just switch lambda` | `just switch omega` |
| Install alias | `just install lambda` | `just install omega` |
| List generations | `just list lambda` | `just list omega` |
| Rollback | `just rollback lambda <generation>` | `just rollback omega <generation>` |
| Clean old generations | `just clean lambda 30d` | `just clean omega 30d` |

`just clean omega <older_than>` deletes old NixOS system generations, rebuilds boot entries, and then runs garbage collection. This is the path to reduce bootloader generation clutter on `omega`.

## Flake Management

- Update one host only:
  - `just update lambda`
  - `just update omega`
- Update a specific input in one host:
  - `just update-flake nixpkgs omega`
  - `just update-flake home-manager lambda`

## Package Layers

Package scope is intentionally split:

- System packages (`environment.systemPackages`):
  - Keep this minimal and OS-admin focused.
  - Example: `modules/nixos/system-packages.nix`
- Home Manager packages (`home.packages`):
  - Primary user-facing CLI/GUI package layer.
  - Built from:
    - shared baseline: `modules/shared/packages.nix`
    - OS-specific additions: `modules/macos/packages.nix`, `modules/nixos/packages.nix`
- Host-specific hardware/system modules:
  - Keep hardware and boot choices in host files (for example `hosts/omega/configuration.nix`).

## Hyprland On `omega`

Hyprland is configured in two layers:

- System/session enablement: `modules/nixos/desktop.nix`
- User config (Home Manager): `modules/nixos/home-manager/hyprland.nix`

The Home Manager module intentionally follows an Omarchy-style split config:

- `~/.config/hypr/hyprland.conf` sources:
  - `monitors.conf`
  - `envs.conf`
  - `input.conf`
  - `looknfeel.conf`
  - `workspaces.conf`
  - `windows.conf`
  - `bindings.conf`
  - `autostart.conf`

Default behavior:

- `kitty` is installed, and Hyprland keybinds default to `wezterm`.
- Workspaces `1..10` are persistent.
- Startup script maps workspaces `1..5` to monitor 1 and `6..10` to monitor 2.
- App-to-workspace rules are defined in `windows.conf`.

Customization tips:

- Run `hyprctl monitors`, then tune `monitors.conf` if you want explicit output names/scales.
- Run `hyprctl clients`, then adjust app matching rules in `windows.conf`.
- Update keybinds in `bindings.conf` to match your preferred window-management muscle memory.

## QA

Tooling comes from host-specific flakes:

- `just fmt`
- `just fmt-check`
- `just lint`

On macOS these run via `path:.?dir=hosts/lambda`; on Linux they run via `path:.?dir=hosts/omega`.

## Directory Structure

```sh
nixos-config/
├── hosts/
│   ├── lambda/
│   │   ├── default.nix
│   │   ├── flake.lock
│   │   └── flake.nix
│   └── omega/
│       ├── bluetooth.nix
│       ├── boot.nix
│       ├── configuration.nix
│       ├── default.nix
│       ├── flake.lock
│       ├── flake.nix
│       ├── hardware-configuration.nix
│       └── video.nix
├── justfile
└── modules/
    ├── macos/
    │   └── ...
    ├── nixos/
    │   ├── programs/
    │   │   ├── default.nix
    │   │   └── ...
    │   └── ...
    └── shared/
        ├── default.nix
        └── packages.nix
```
