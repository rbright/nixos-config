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

## NixOS Dotfiles

NixOS dotfiles are now vendored in this repository and sourced by Home
Manager using native config files:

- Dotfile source root:
  - `modules/nixos/home-manager/dotfiles/`
- Home Manager module:
  - `modules/nixos/home-manager/dotfiles.nix`
- Wiring:
  - `modules/nixos/home-manager.nix` (applies to NixOS hosts)

Before first NixOS host switch from this repo, remove existing Stow-managed
links on that machine from the dotfiles repository:

```sh
cd /Users/rbright/Projects/dotfiles
STOW_FLAGS="-nv" just uninstall <host>
just uninstall <host>
```

Then apply the NixOS config from this repository:

```sh
cd /Users/rbright/Projects/nixos-config
just switch <host>
```

## Hyprland On `omega`

Hyprland is configured in two layers:

- System/session enablement: `modules/nixos/desktop.nix`
- Package/runtime wiring: `modules/nixos/home-manager/hyprland.nix`
- Native config files (dotfiles):
  - `modules/nixos/home-manager/dotfiles/hypr/.config/hypr/hyprland.conf`
  - `modules/nixos/home-manager/dotfiles/waybar/.config/waybar/{config,style.css}`
  - `modules/nixos/home-manager/dotfiles/mako/.config/mako/config`

Default behavior:

- `kitty` is installed.
- `wofi` is installed as a minimal app launcher.
- `gnome-control-center` is installed so GNOME Settings can be launched from Hyprland.
- `waybar` and `mako` are launched at Hyprland startup.
- Hyprland keeps a small keybind set:
  - `SUPER + Return`: open `wezterm`
  - `SUPER + D` or `SUPER + Space`: open launcher (`wofi`)
  - `SUPER + G`: open GNOME Settings (`gnome-control-center`)
  - `SUPER + Shift + 3`: full screenshot to `~/Pictures/Screenshots`
  - `SUPER + Shift + 4`: region screenshot to `~/Pictures/Screenshots`
  - `SUPER + Shift + 5`: region screenshot to clipboard
  - `SUPER + Shift + Q`: close active window
  - `SUPER + Shift + R`: reload Hyprland config
  - `SUPER + Shift + M`: exit Hyprland session

## 1Password SSH Agent On `omega`

- NixOS SSH client is configured to use 1Password agent socket:
  - `modules/nixos/ssh.nix` sets:
    - `Host *`
    - `IdentityAgent ~/.1password/agent.sock`
- NixOS Git config is defined natively via Home Manager module wiring:
  - `modules/nixos/programs/git.nix`
  - `home-manager.users.<user>.programs.git.settings."gpg \"ssh\"".program = <1Password op-ssh-sign path>`

In 1Password desktop app, enable SSH agent integration:

- `Settings` -> `Developer` -> `Use the SSH agent`

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
