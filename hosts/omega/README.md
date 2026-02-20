# `omega` (NixOS Host)

## Purpose

`omega` is the NixOS host assembled with `nixosSystem` + `home-manager`.

## Authoritative Files

- `flake.nix`: host flake inputs and `nixosConfigurations.omega`
- `default.nix`: host-local hostname wiring
- `configuration.nix`: host-specific imports + `system.stateVersion`
- Host-only modules:
  - `bluetooth.nix`
  - `boot.nix`
  - `hardware-configuration.nix`
  - `nas.nix`
  - `speech.nix`
  - `thunderbolt.nix`
  - `video.nix`

## Composition

`nixosConfigurations.omega` includes:

1. `home-manager.nixosModules.home-manager`
2. host overlays/package injections
3. `modules/shared/`
4. `modules/nixos/`
5. optional service flakes from `inputs`
6. `hosts/omega/default.nix`

## Local Input Paths

Some inputs may be local path flakes (for example, in-development modules). Use portable placeholders in documentation and configure your real absolute paths in `flake.nix`:

```nix
url = "path:/<absolute-path-to-local-flake>";
```

## Common Workflows

```sh
just build omega
just switch omega
```

Success looks like: build and switch complete without evaluation errors.

## Host-Specific Runtime Features

### Speech-to-text service wiring

- Config: `speech.nix`
- Secret env file expected at: `$HOME/.config/riva/riva-nim.env`

Template:

```sh
install -d -m 700 "$HOME/.config/riva"
cat > "$HOME/.config/riva/riva-nim.env" <<'EOF'
NGC_API_KEY=<your-ngc-api-key>
EOF
chmod 600 "$HOME/.config/riva/riva-nim.env"
```

### NAS mount

- Config: `nas.nix`
- Mount point: `/mnt/unifi-drive`
- Update export/host values in `nas.nix` for your environment.

Verify:

```sh
sudo mount -v /mnt/unifi-drive
ls /mnt/unifi-drive
```

For user-session services (rclone/gcsfuse/desktop), see [`../../modules/nixos/home-manager/README.md`](../../modules/nixos/home-manager/README.md).
