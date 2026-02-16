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

### Passwordless Rebuild On `omega`

`modules/nixos/sudo.nix` grants `NOPASSWD` for:

- `/run/current-system/sw/bin/nixos-rebuild`

This removes the sudo password prompt for `just switch omega` while keeping
password prompts for unrelated privileged commands.

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
- `vicinae` is configured as the default app launcher (`$launcher = vicinae toggle` in Hyprland variables).
- Vicinae daemon setup follows official NixOS guidance via Home Manager:
  - `modules/nixos/home-manager/vicinae.nix` enables `programs.vicinae`
  - user service auto-start is managed by `programs.vicinae.systemd.enable = true`
  - baseline settings from `https://docs.vicinae.com/nixos#configuring-with-home-manager`
  - extensions enabled: `bluetooth`, `nix`, `power-profile`
  - dark theme baseline: `catppuccin-mocha`
  - clipboard history is pinned in favorites (`clipboard:history`)
- `gnome-control-center` is installed so GNOME Settings can be launched from Hyprland.
- `waybar`, `mako`, `hyprpaper`, and `hypridle` are launched at Hyprland startup.
- Hyprpaper is launched with explicit config path
  (`hyprpaper -c ~/.config/hypr/hyprpaper.conf`) and pins
  `~/.config/hypr/wallpapers/cat-waves-mocha.png` to all connected monitors.
- Hyprlock and Hypridle are configured declaratively via:
  - `modules/nixos/home-manager/dotfiles/hypr/.config/hypr/hyprlock.conf`
  - `modules/nixos/home-manager/dotfiles/hypr/.config/hypr/hypridle.conf`
  - idle policy: lock at 5 min, DPMS off at 5.5 min, suspend at 30 min.
- Main monitor (`DP-5`, AW3225QF) is pinned to `3840x2160@239.99`.
- Waybar workspace buttons are rendered as compact numeric labels (`1..10`).
- Waybar center clock shows localized date + time (`%B %d @ %H:%M`).
- Waybar module clicks:
  - network: `nm-connection-editor` (fallback: `wezterm -e nmtui`)
  - audio: `hyprpwcenter` (fallback: `pavucontrol`, then `wpctl ... toggle mute`)
  - bluetooth: `blueman-manager` (fallback: `wezterm -e bluetoothctl`)
- Waybar right modules include tray, bluetooth, network, audio, and battery.
- GNOME Calendar is installed and set as the default calendar handler for
  `webcal` and `.ics` links via `xdg.mimeApps`.
- GNOME Online Accounts and Evolution Data Server system daemons are enabled
  (`services.gnome.gnome-online-accounts`, `services.gnome.evolution-data-server`)
  so GNOME Calendar can sync connected providers under Hyprland.
- `greetd` with ReGreet is the login manager for `omega`:
  - launched through `cage` by `programs.regreet` defaults
  - themed with Catppuccin + IBM Plex Sans to align with Hyprlock styling
  - configured to prefer the UWSM Hyprland session path by hiding the plain
    `hyprland.desktop` entry in ReGreet session discovery
  - ReGreet state cache (`/var/lib/regreet/state.toml`) remembers last user and
    session selection between logins
- Waybar and Mako typography use `IBM Plex Sans` with:
  - Waybar: `16px`
  - Mako: `12`
- GTK icon theme uses Catppuccin-tinted Papirus folders (`catppuccin-papirus-folders`)
  while keeping the `Papirus-Dark` theme name for compatibility.
- Cursor theme is declarative in `modules/nixos/home-manager/hyprland.nix` via
  `home.pointerCursor` (`catppuccin-mocha-blue-cursors`, size `24` by default).
- `Caps Lock` is remapped to Hyper via XKB option `caps:hyper`.
- Key repeat is tuned faster (`repeat_rate = 55`, `repeat_delay = 250`).
- GTK/GNOME interface font baseline is `Inter 12` to avoid oversized Chromium/Brave chrome text.
- Hyper app bindings are used only for app focus/launch:
  - `Hyper + <key>`: focus/switch to app window if present, otherwise launch.
  - `Hyper + Shift + <same key>`: launch a new window/instance for that app.
  - `Hyper + F` targets GNOME Calendar (`gnome-calendar`) on workspace `8`.
- Brave context split is declarative and profile-safe:
  - `brave-personal` uses `~/.config/BraveSoftware/Brave-Browser`.
  - `brave-work` uses `~/.config/BraveSoftware/Brave-Browser-Work`.
  - default browser handlers (`http`, `https`, `text/html`) prefer `brave-personal`.
  - Hypr web-app launchers (`todoist`, `linear`, `messages`,
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
- Thunar is configured declaratively for `omega`:
  - system enablement via `modules/nixos/programs/thunar.nix`
  - default directory handler via `modules/nixos/home-manager/thunar.nix`
  - preferred startup view set to `ThunarDetailsView` (List/Details mode)
- Utility keybinds remain in place:
  - `SUPER + Return`: open `wezterm`
  - `SUPER + P`: open color picker (`hyprpicker -a -f hex`)
  - `SUPER + Space` (and fallback `CTRL + Space`): open launcher (`vicinae toggle`)
  - `ALT + SUPER + C`: open Vicinae clipboard history (`vicinae://extensions/vicinae/clipboard/history`)
  - `HYPER + G`: open GNOME Settings (`gnome-control-center`)
  - `CTRL + ALT + SUPER + L`: lock screen (`hyprlock`)
  - `CTRL + ALT + SUPER + E`: open Vicinae emoji picker
    (`vicinae://extensions/vicinae/emoji/search`)
  - `SUPER + Shift + 3`: full screenshot to `~/Pictures/Screenshots`
  - `SUPER + Shift + 4`: region screenshot to `~/Pictures/Screenshots`
  - `SUPER + Shift + 5`: region screenshot to clipboard
  - `SUPER + Q`: close active window
  - `SUPER + Shift + R`: restart Waybar + Mako, then reload Hyprland config
  - `SUPER + Shift + M`: exit Hyprland session

Connect online accounts for GNOME Calendar:

```sh
gnome-online-accounts-settings
```

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

## UniFi Drive NFS On `omega`

- NFS client support and mount wiring are defined in:
  - `hosts/omega/nas.nix`
  - mount point: `/mnt/unifi-drive`
  - mount type: `nfs` with `nofail` + `x-systemd.automount` safety options
- Set the UniFi console endpoint in `hosts/omega/nas.nix`:
  - current default: `192.168.31.119:/` (NFSv4 pseudo-root for discovery)
  - once you confirm the exact export path, replace with that specific export.

Apply and test:

```sh
cd /home/rbright/Projects/nixos-config
just switch omega
ls /mnt/unifi-drive
thunar /mnt/unifi-drive
```

## llama.cpp On `omega`

- NixOS host config enables managed llama.cpp service in:
  - `modules/nixos/llama-cpp.nix`
  - `services.llama-cpp.enable = true`
  - `services.llama-cpp.package = pkgs.llama-cpp.override { cudaSupport = true; }`
  - `services.llama-cpp.modelsDir = /var/lib/llama-cpp/models`

Apply and verify on `omega`:

```sh
cd /home/rbright/Projects/nixos-config
just switch omega
systemctl status llama-cpp.service --no-pager
curl -s http://127.0.0.1:11434/v1/models | jq .
```

Populate the model directory with GGUF files:

```sh
sudo install -d -m 0755 /var/lib/llama-cpp/models
sudo cp /path/to/*.gguf /var/lib/llama-cpp/models/
sudo systemctl restart llama-cpp.service
```

Live service logs:

```sh
journalctl -u llama-cpp.service -f
```

Nushell command helpers (after `just switch omega`):

```sh
llm start
llm stop
llm restart
llm download <gguf-url>
llm list
llm message "Explain the NixOS module system in 3 bullets."
mistral "Explain the NixOS module system in 3 bullets."
llm logs
llm logs --follow
```

## QA

Tooling comes from host-specific flakes:

- `just fmt`
- `just fmt-check`
- `just lint`
- `just hypr-smoke` (runtime Hyprland smoke test)
  - Run after `just switch omega` from inside an active Hyprland session.

On macOS these run via `path:.?dir=hosts/lambda`; on Linux they run via `path:.?dir=hosts/omega`.

Pre-commit hooks are defined in `.pre-commit-config.yaml` and currently run `just lint` before each commit:

```sh
prek install
prek run -a
```

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
