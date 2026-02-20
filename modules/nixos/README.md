# NixOS Modules (`modules/nixos`)

## Purpose

This directory contains NixOS modules consumed by `hosts/omega/flake.nix`.

## Entry Points

- `default.nix`: imports the NixOS module set.
- `home-manager.nix`: wires Home Manager for the primary user.
- `programs/`: program-specific modules (Git, 1Password, Firefox, Thunar).

## Core Module Areas

- System/runtime: `audio.nix`, `bluetooth.nix`, `desktop.nix`, `docker.nix`, `keyring.nix`, `networking.nix`, `printing.nix`, `ssh.nix`, `sudo.nix`, `tailscale.nix`, `user.nix`
- Tooling/packages: `system-packages.nix`, `packages.nix`, `nix-ld.nix`
- Services: `llama-cpp.nix`
- Home Manager user layer: `home-manager/*.nix`

## Related Guides

- Home Manager layer: [`home-manager/README.md`](home-manager/README.md)
- Program modules: [`programs/README.md`](programs/README.md)
- Host overrides: [`../../hosts/omega/README.md`](../../hosts/omega/README.md)

## Service Runbook Snippets

### Tailscale SSH (`tailscale.nix`)

```sh
just switch omega
sudo tailscale up --ssh
tailscale status --self
```

### llama.cpp (`llama-cpp.nix`)

```sh
just switch omega
systemctl status llama-cpp.service --no-pager
curl -s http://127.0.0.1:11434/v1/models | jq .
```

## Verification

```sh
just lint
just build omega
just switch omega
```

If desktop runtime config changed under `home-manager/dotfiles/hypr`, `waybar`, or `mako`, also run:

```sh
just hypr-smoke
```
