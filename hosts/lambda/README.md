# `lambda` (macOS Host)

## Purpose

`lambda` is the macOS host built with `nix-darwin`, `home-manager`, and `nix-homebrew`.

## Authoritative Files

- `flake.nix`: host flake inputs and `darwinConfigurations.lambda`
- `default.nix`: host-local hostname wiring

## Module Composition

`darwinConfigurations.lambda` includes:

1. `home-manager.darwinModules.home-manager`
2. `nix-homebrew.darwinModules.nix-homebrew`
3. `modules/shared/`
4. `modules/macos/`
5. `hosts/lambda/default.nix`

## Common Workflows

### Bootstrap a new macOS machine

```sh
just bootstrap lambda
```

### Build and switch

```sh
just build lambda
just switch lambda
```

Success looks like: both commands exit `0` and `darwin-rebuild switch` applies without evaluation errors.

## Customization Notes

- Update host user wiring in `flake.nix` (`specialArgs.user`) for non-default usernames.
- Keep system behavior in `modules/macos/` instead of host files unless strictly host-specific.

## Caveat

`just build lambda` requires a Darwin builder (`aarch64-darwin`) and is expected to fail on Linux-only systems.
