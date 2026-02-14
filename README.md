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

NixOS dotfiles (except Zed and Neovim) are vendored in this repository and sourced by
Home Manager using native config files:

- Dotfile source root:
  - `modules/nixos/home-manager/dotfiles/`
- Home Manager module:
  - `modules/nixos/home-manager/dotfiles.nix`
- Wiring:
  - `modules/nixos/home-manager.nix` (applies to NixOS hosts)

Zed and Neovim are intentionally unmanaged by Home Manager on NixOS. Their
configs are managed via GNU Stow from `/home/rbright/Projects/dotfiles`
(`omega.packages` contains `zed` and `neovim`).

Credential persistence for Zed relies on GNOME Keyring (`services.gnome.gnome-keyring.enable = true`)
to provide the Secret Service backend on NixOS.

To (re)stow Zed/Neovim config on `omega`:

```sh
cd /home/rbright/Projects/dotfiles
STOW_FLAGS="-nv" just install omega
just install omega
```

Then apply the NixOS config from this repository:

```sh
cd /home/rbright/Projects/nixos-config
just switch omega
```

## Hyprland On `omega`

Hyprland is configured in two layers:

- System/session enablement: `modules/nixos/desktop.nix`
- Package/runtime wiring: `modules/nixos/home-manager/hyprland.nix`
- Native config files (dotfiles):
  - `modules/nixos/home-manager/dotfiles/hypr/.config/hypr/hyprland.conf`
  - `modules/nixos/home-manager/dotfiles/hypr/.config/hypr/scripts/app-dispatch.sh`
  - `modules/nixos/home-manager/dotfiles/waybar/.config/waybar/{config,style.css}`
  - `modules/nixos/home-manager/dotfiles/mako/.config/mako/config`

Default behavior:

- `kitty` is installed.
- `wofi` is installed as a minimal app launcher.
- `gnome-control-center` is installed so GNOME Settings can be launched from Hyprland.
- `waybar`, `mako`, and `hyprpaper` are launched at Hyprland startup.
- Hyprpaper is launched with explicit config path
  (`hyprpaper -c ~/.config/hypr/hyprpaper.conf`) and pins
  `~/.config/hypr/wallpapers/cat-waves-mocha.png` to each monitor
  (`DP-5`, `DP-1`, plus a fallback for any additional monitor).
- Main monitor (`DP-5`, AW3225QF) is pinned to `3840x2160@239.99`.
- Waybar workspace buttons are rendered as compact numeric labels (`1..10`).
- Waybar center clock shows localized date + time (`%B %d @ %H:%M`).
- Waybar module clicks:
  - network: `nm-connection-editor` (fallback: `wezterm -e nmtui`)
  - audio: `pavucontrol` (fallback: `wpctl ... toggle mute`)
  - bluetooth: `blueman-manager` (fallback: `wezterm -e bluetoothctl`)
- Waybar includes a right-side logout icon (``) that exits Hyprland.
- Waybar/Mako UI typography uses `Inter` sizing (`12`) with Nerd Font fallback for icon glyphs.
- GTK icon theme uses Catppuccin-tinted Papirus folders (`catppuccin-papirus-folders`)
  while keeping the `Papirus-Dark` theme name for compatibility.
- Cursor theme is declarative in `modules/nixos/home-manager/hyprland.nix` via
  `home.pointerCursor` (`Bibata-Modern-Ice`, size `24` by default).
- `Caps Lock` is remapped to Hyper via XKB option `caps:hyper`.
- Key repeat is tuned faster (`repeat_rate = 55`, `repeat_delay = 250`).
- GTK/GNOME interface font baseline is `Inter 12` to avoid oversized Chromium/Brave chrome text.
- Hyper app bindings are used only for app focus/launch:
  - `Hyper + <key>`: focus/switch to app window if present, otherwise launch.
  - `Hyper + Shift + <same key>`: launch a new window/instance for that app.
- Brave context split is declarative and profile-safe:
  - `brave-personal` uses `~/.config/BraveSoftware/Brave-Browser`.
  - `brave-work` uses `~/.config/BraveSoftware/Brave-Browser-Work`.
  - Hypr web-app launchers (`calendar`, `todoist`, `linear`, `messages`,
    `agent-monitor`, and mail fallback) launch with `brave-work`.
- AeroSpace-like workspace model is defined and persisted:
  - `1` (general), `2` (code), `3` (dev tools), `4` (notes/office),
    `5` (planning), `6` (trading), `7` (messaging), `8` (calendar),
    `9` (agent monitor), `10` (terminal)
  - Workspace-to-monitor split mirrors AeroSpace:
    - `1..8` are pinned to the main monitor.
    - `9..10` are pinned to the secondary monitor.
  - `Alt + 1..0` switches workspaces; `Alt + Shift + 1..0` moves windows.
- Keybind scope is intentionally minimal:
  - app launch/focus (`Hyper`)
  - workspace switching/move (`Alt + 1..0`)
  - window management (`Super + H/J/K/L` focus, `Super + Shift + H/J/K/L` move)
  - screenshots (`Super + Shift + 3/4/5`)
- `Super + [` and `Super + ]` send `Ctrl+Shift+Tab` and `Ctrl+Tab` to provide
  consistent tab navigation in Brave, Zed, and other tabbed apps.
- Catppuccin palette sources are vendored:
  - `modules/nixos/home-manager/dotfiles/waybar/.config/waybar/themes/catppuccin.css`
  - `modules/nixos/home-manager/dotfiles/hypr/.config/hypr/themes/catppuccin/colors.toml`
- Hyprland layout is configured with zero outer/inner gaps to avoid wallpaper
  space at screen edges.
- GTK file dialogs are forced dark via Catppuccin GTK theme + `prefer-dark`
  interface setting + GTK portal backend.
- Utility keybinds remain in place:
  - `SUPER + Return`: open `wezterm`
  - `SUPER + Space` (and fallback `CTRL + Space`): open launcher (`wofi`)
  - `HYPER + G`: open GNOME Settings (`gnome-control-center`)
  - `CTRL + ALT + SUPER + L`: lock screen (`hyprlock`)
  - `SUPER + Shift + 3`: full screenshot to `~/Pictures/Screenshots`
  - `SUPER + Shift + 4`: region screenshot to `~/Pictures/Screenshots`
  - `SUPER + Shift + 5`: region screenshot to clipboard
  - `SUPER + Q`: close active window
  - `SUPER + Shift + R`: reload Hyprland config
  - `SUPER + Shift + M`: exit Hyprland session

## 1Password SSH Agent On `omega`

- NixOS SSH client is configured to use 1Password agent socket:
  - `modules/nixos/ssh.nix` sets:
    - `Host *`
    - `IdentityAgent ~/.1password/agent.sock`
- NixOS Git config is defined natively via Home Manager module wiring:
  - `modules/nixos/programs/git.nix`
  - `gpg.format = ssh`
  - `user.signingKey = ~/.ssh/id_ed25519.pub`
  - `gpg.ssh.program = ssh-keygen`
  - `gpg.ssh.allowedSignersFile = ~/.ssh/allowed_signers`

In 1Password desktop app, enable SSH agent integration:

- `Settings` -> `Developer` -> `Use the SSH agent`

Create `~/.ssh/allowed_signers` for local signature verification:

```sh
printf '%s %s\n' "$(git config user.email)" "$(cat ~/.ssh/id_ed25519.pub)" > ~/.ssh/allowed_signers
chmod 600 ~/.ssh/allowed_signers
```

## Tailscale SSH On `omega`

- NixOS host config enables Tailscale + Tailscale SSH in:
  - `modules/nixos/tailscale.nix`
  - `services.tailscale.enable = true`
  - `services.tailscale.openFirewall = true`
  - `services.tailscale.extraSetFlags = [ "--ssh=true" ]`

One-time onboarding on `omega`:

```sh
cd /home/rbright/Projects/nixos-config
just switch omega
```

Then authenticate the node with one of:

```sh
# Interactive auth flow (prints login URL)
sudo tailscale up --ssh

# Admin-issued machine key flow
sudo tailscale up --ssh --auth-key 'tskey-...'
```

Verify:

```sh
tailscale status --self
tailscale ip -4
```

Connect from another tailnet device:

- macOS OpenSSH client:
  - `ssh rbright@omega`
- Android Termius:
  - Ensure Android Tailscale app is connected first.
  - Target host `omega` (MagicDNS) or the `100.x.y.z` address from `tailscale ip -4`.

After `omega` connectivity is confirmed, macOS host OpenSSH can be removed.

## QA

Tooling comes from host-specific flakes:

- `just fmt`
- `just fmt-check`
- `just lint`
- `just hypr-smoke` (runtime Hyprland smoke test)
  - Run after `just switch omega` from inside an active Hyprland session.

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
