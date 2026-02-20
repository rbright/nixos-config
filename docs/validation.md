# Validation and CI Parity

Use this checklist before hand-off.

## Baseline Checks

From repo root:

```sh
just lint
just build omega
```

If your change affects `lambda` and you are on macOS (or have a Darwin builder):

```sh
just build lambda
```

If your change touches Hyprland runtime config (`modules/nixos/home-manager/dotfiles/hypr`, `waybar`, `mako`), also run:

```sh
just hypr-smoke
```

Success looks like: each command exits `0`.

## Documentation Checks

### Verify command surface exists

```sh
just --list
```

### Validate relative doc links

```sh
python3 ~/.agents/skills/update-docs/check-doc-links.py
```

Success looks like: `All markdown links are valid.`

## CI Parity

GitHub Actions lint workflow runs:

```sh
nix run nixpkgs#just -- lint
```

## Optional Local Pre-commit Loop

```sh
prek install
prek run -a
```

Run this when modifying Nix code or enforcing local hook parity.
