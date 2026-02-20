# Module Layout

This directory contains reusable Nix modules grouped by scope.

## Module Index

- [`shared/README.md`](shared/README.md): cross-host policies and shared packages.
- [`macos/README.md`](macos/README.md): `nix-darwin` modules for `lambda`.
- [`nixos/README.md`](nixos/README.md): NixOS modules for `omega`.

## Design Rules

- Put cross-host policy in `shared/`.
- Put OS-specific behavior in `macos/` or `nixos/`.
- Keep host-only concerns in `hosts/<host>/`.

## Verification

```sh
just lint
just build omega
# If macOS modules changed and Darwin builder is available:
just build lambda
```
