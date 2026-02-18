# Multi-Host Nix Configuration

This repository manages two host-specific Nix flakes:

- `lambda`: macOS (`nix-darwin` + `home-manager` + `nix-homebrew`)
- `omega`: NixOS (`nixosSystem` + `home-manager`)

## Start Here (Entrypoint)

### Prerequisites

- Nix with flakes enabled (`nix --version`)
- [`just`](https://github.com/casey/just) (`just --version`)
- Git checkout of this repo

### First successful run (fast path)

```sh
just --list
just build omega
```

Success looks like:

- `just --list` prints recipe groups (`bootstrap`, `nix`, `qa`)
- `just build omega` exits with code `0`

### First successful run on macOS host (`lambda`)

```sh
just bootstrap lambda
just build lambda
just switch lambda
```

Success looks like:

- bootstrap completes Xcode CLI tools + Nix install prompt flow
- build/switch complete without evaluation errors

> [!NOTE]
> `just build lambda` requires a Darwin builder (`aarch64-darwin`). Running this on Linux fails by design.

## Daily Command Reference

Run `just --list` for the full catalog.

| Operation | Lambda (macOS) | Omega (NixOS) |
|---|---|---|
| Build | `just build lambda` | `just build omega` |
| Install / Switch | `just switch lambda` | `just switch omega` |
| Install alias | `just install lambda` | `just install omega` |
| Update host lockfile | `just update lambda` | `just update omega` |
| Update one flake input | `just update-flake nixpkgs lambda` | `just update-flake nixpkgs omega` |
| List generations | `just list lambda` | `just list omega` |
| Roll back generation | `just rollback lambda <generation>` | `just rollback omega <generation>` |
| Clean old generations | `just clean lambda 30d` | `just clean omega 30d` |

`just clean omega <older_than>` deletes old generations, rebuilds boot entries, then runs GC.

## Validation, CI, and Contributor Loop

### Local validation

```sh
just fmt-check
just lint
just build omega
```

If you changed `lambda`-scoped config, also run:

```sh
just build lambda
```

### CI parity

GitHub Actions (`.github/workflows/lint.yml`) runs:

```sh
nix run nixpkgs#just -- lint
```

### Pre-commit

```sh
prek install
prek run -a
```

Success looks like:

- no `statix`/`deadnix`/`nixfmt` failures
- clean exit code (`0`)

## Architecture and Source of Truth

| Concern | Authoritative source |
|---|---|
| Command surface | `justfile` |
| macOS host flake/lock | `hosts/lambda/flake.nix`, `hosts/lambda/flake.lock` |
| NixOS host flake/lock | `hosts/omega/flake.nix`, `hosts/omega/flake.lock` |
| Shared Nix policy | `modules/shared/` |
| macOS modules | `modules/macos/` |
| NixOS modules | `modules/nixos/` |
| NixOS Home Manager wiring | `modules/nixos/home-manager.nix` |
| NixOS dotfile declarations | `modules/nixos/home-manager/dotfiles.nix` + `modules/nixos/home-manager/dotfiles/` |
| `pi-agent` package source | `github:rbright/nix-pi-agent` (wired in `hosts/omega/flake.nix`) |

Host outputs:

- `path:.?dir=hosts/lambda#darwinConfigurations.lambda`
- `path:.?dir=hosts/omega#nixosConfigurations.omega`

### Package layering

- System packages (`environment.systemPackages`): minimal, OS-admin focused
  - Example: `modules/nixos/system-packages.nix`
- User packages (`home.packages`): daily CLI/GUI tools
  - shared baseline: `modules/shared/packages.nix`
  - OS additions: `modules/macos/packages.nix`, `modules/nixos/packages.nix`
- `pi-agent` package workflow:
  - source repository: `https://github.com/rbright/nix-pi-agent`
  - flake input wiring: `hosts/omega/flake.nix` (`inputs.nixPiAgent`)
  - package consumption: `modules/nixos/packages.nix`

### NixOS dotfiles scope

Most NixOS dotfiles are vendored under:

- `modules/nixos/home-manager/dotfiles/`
- wired by `modules/nixos/home-manager/dotfiles.nix`

Zed and Neovim remain intentionally external (GNU Stow in `/home/rbright/Projects/dotfiles`):

```sh
cd /home/rbright/Projects/dotfiles
STOW_FLAGS="-nv" just install omega
just install omega
```

Then re-apply this repo's host config:

```sh
cd /home/rbright/Projects/nixos-config
just switch omega
```

## Omega Runtime Runbooks (Optional Depth)

<details>
<summary><strong>Hyprland desktop (`omega`)</strong></summary>

**Authoritative files**

- Session/system enablement: `modules/nixos/desktop.nix`
- Home Manager package/runtime wiring: `modules/nixos/home-manager/hyprland.nix`
- Dotfiles root: `modules/nixos/home-manager/dotfiles/hypr/.config/hypr/`
- Waybar config:
  - `modules/nixos/home-manager/dotfiles/waybar/.config/waybar/config.jsonc`
  - `modules/nixos/home-manager/dotfiles/waybar/.config/waybar/modules.jsonc`
  - `modules/nixos/home-manager/dotfiles/waybar/.config/waybar/style.css`

**Default behavior highlights**

- Launcher: `vicinae toggle` (bound to `CTRL + SPACE`)
- File manager: Thunar (`SUPER + E`)
- Terminals: WezTerm (`SUPER + RETURN`) + Ghostty (`SUPER + grave`)
- Workspace model: persistent `1..10`; `1..8` on main monitor, `9..10` on secondary
- Waybar center clock: `%H:%M`
- Waybar right modules: tray expander, audio, bluetooth, network, CPU, memory
- Keyring + sync support: `services.gnome.gnome-keyring.enable = true`
- GNOME Online Accounts helper command:

```sh
gnome-online-accounts-settings
```

**High-signal keybinds**

| Shortcut | Action |
|---|---|
| `CTRL + SPACE` | Open Vicinae launcher |
| `ALT + SUPER + C` | Open Vicinae clipboard history |
| `CTRL + ALT + SUPER + E` | Open Vicinae emoji search |
| `SUPER + Shift + 3/4/5` | Full save / region save / region to clipboard screenshot |
| `ALT + 1..0` | Switch workspace |
| `ALT + Shift + 1..0` | Move window to workspace |
| `Hyper + <key>` | Focus app (or launch if missing), except Linear |
| `Hyper + L` | Focus existing Linear window only |
| `Hyper + U` | Focus Cider (or launch if missing) |
| `Hyper + Shift + <key>` | Launch new app instance (including `Hyper + Shift + L` for Linear) |
| `SUPER + [` / `SUPER + ]` | Send browser/editor tab back/forward shortcuts |

**Verification commands**

```sh
just switch omega
hyprctl -j configerrors | jq .
just hypr-smoke
```

</details>

<details>
<summary><strong>1Password SSH agent + Git signing (`omega`)</strong></summary>

**Authoritative files**

- SSH agent socket config: `modules/nixos/ssh.nix`
- Git config: `modules/nixos/programs/git.nix`

**Workflow**

1. Enable SSH agent in 1Password Desktop:
   - `Settings -> Developer -> Use the SSH agent`
2. Ensure allowed signers file exists:

```sh
printf '%s %s\n' "$(git config user.email)" "$(cat ~/.ssh/id_ed25519.pub)" > ~/.ssh/allowed_signers
chmod 600 ~/.ssh/allowed_signers
```

Success looks like: Git can sign commits with SSH format and `IdentityAgent ~/.1password/agent.sock` is active.

</details>

<details>
<summary><strong>Tailscale SSH (`omega`)</strong></summary>

**Authoritative file**: `modules/nixos/tailscale.nix`

Apply + onboard:

```sh
just switch omega
sudo tailscale up --ssh
```

Verify:

```sh
tailscale status --self
tailscale ip -4
```

Success looks like: node is online and reachable via `ssh rbright@omega` from another tailnet device.

</details>

<details>
<summary><strong>UniFi Drive NFS mount (`omega`)</strong></summary>

**Authoritative file**: `hosts/omega/nas.nix`

Current mount target:

- mount point: `/mnt/unifi-drive`
- export: `192.168.31.119:/volume/3351ce27-74cc-4650-8150-68d70281a854/.srv/.unifi-drive/Shared/.data`

Apply + test:

```sh
just switch omega
sudo mount -v /mnt/unifi-drive
ls /mnt/unifi-drive
thunar /mnt/unifi-drive
```

Success looks like: directory listing works and mount is browseable in Thunar.

</details>

<details>
<summary><strong>Google Drive via rclone (`omega`)</strong></summary>

**Authoritative file**: `modules/nixos/home-manager/rclone.nix`

One-time OAuth setup:

```sh
rclone config
```

- Remote name must be `gdrive`

Apply + test:

```sh
just switch omega
systemctl --user daemon-reload
systemctl --user enable --now rclone-gdrive.service
systemctl --user status rclone-gdrive.service --no-pager
ls ~/GoogleDrive
```

Success looks like: `rclone-gdrive.service` is active and `~/GoogleDrive` is mounted.

</details>

<details>
<summary><strong>llama.cpp service + helpers (`omega`)</strong></summary>

**Authoritative file**: `modules/nixos/llama-cpp.nix`

Apply + verify:

```sh
just switch omega
systemctl status llama-cpp.service --no-pager
curl -s http://127.0.0.1:11434/v1/models | jq .
```

Populate model directory:

```sh
sudo install -d -m 0755 /var/lib/llama-cpp/models
sudo cp /path/to/*.gguf /var/lib/llama-cpp/models/
sudo systemctl restart llama-cpp.service
```

Helper commands (after switch):

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

</details>

## Troubleshooting

- **`just build lambda` fails on Linux with `required system ... aarch64-darwin`**
  - Expected when not on macOS/Darwin builder.
- **`just hypr-smoke` reports bind mismatches**
  - Ensure the active Home Manager generation is applied first:
    ```sh
    just switch omega
    hyprctl reload
    ```
  - Re-run `just hypr-smoke`; if it still fails, use the script’s manual E2E checklist section for runtime confirmation.
- **NFS mount does not resolve**
  - Verify export path from UniFi host:
    ```sh
    showmount -e 192.168.31.119
    ```
  - Update `hosts/omega/nas.nix` if UniFi export path changed.
- **`rclone-gdrive.service` does not start**
  - Confirm config exists at `~/.config/rclone/rclone.conf` and includes remote `gdrive`.
- **`just lint` fails on warnings**
  - `statix` warnings are treated as failures in the current lint recipe.

## Additional Documentation

- `pi-agent` package repository: `https://github.com/rbright/nix-pi-agent`

## Directory Structure

```text
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
│       ├── nas.nix
│       ├── thunderbolt.nix
│       └── video.nix
├── justfile
└── modules/
    ├── macos/
    ├── nixos/
    │   ├── home-manager/
    │   └── programs/
    └── shared/
```

## Ownership / Help

For doc or workflow drift, open a PR in this repository and update the nearest authoritative source (`justfile`, module, or package README) in the same change.