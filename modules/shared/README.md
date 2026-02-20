# Shared Modules

## Purpose

`modules/shared/` defines policy reused by both hosts.

## Files

- `default.nix`: imports shared modules and sets shared `nixpkgs.config` policy.
- `nix.nix`: shared Nix settings (flakes, substituters, trusted keys).
- `fonts.nix`: shared font package set.
- `packages.nix`: shared user package baseline.

## When to Edit Here

Edit shared modules when behavior should apply to both `lambda` and `omega`.

If behavior is OS-specific, use `modules/macos/` or `modules/nixos/` instead.

## Verification

```sh
just lint
just build omega
# If change impacts lambda and Darwin builder is available:
just build lambda
```
