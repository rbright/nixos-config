# Host Configurations

This directory contains host-specific flake entrypoints and host-local module wiring.

## Host Index

- [`lambda/README.md`](lambda/README.md): macOS (`nix-darwin`) host.
- [`omega/README.md`](omega/README.md): NixOS host.

## Source of Truth

| Concern          | File(s)                                                           |
| ---------------- | ----------------------------------------------------------------- |
| macOS host graph | `lambda/flake.nix`, `lambda/default.nix`                          |
| NixOS host graph | `omega/flake.nix`, `omega/default.nix`, `omega/configuration.nix` |
| Host lock data   | `lambda/flake.lock`, `omega/flake.lock`                           |

## Common Verification

```sh
just lint
just build omega
# On macOS/Darwin builder only:
just build lambda
```
