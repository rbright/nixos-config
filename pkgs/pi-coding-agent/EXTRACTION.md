# Standalone Extraction Guide

Use this when you are ready to publish `pkgs/pi-coding-agent` as its own repo.

## Fast Path

From monorepo root:

```sh
./pkgs/pi-coding-agent/scripts/scaffold-standalone.sh /tmp/pi-coding-agent-nix
```

This creates a standalone layout with:

- package files (`package.nix`, `default.nix`, `flake.nix`, `flake.lock`)
- update helper (`scripts/update-package.sh`)
- docs (`README.md`)
- repo scaffolding (`.gitignore`, `justfile`, `.github/workflows/ci.yml`)

## Publish Checklist

1. Initialize repo:
   - `cd /tmp/pi-coding-agent-nix`
   - `git init`
2. Validate locally:
   - `nix flake check --all-systems`
   - `nix build -L .#pi-coding-agent`
   - `nix run .#pi-coding-agent -- --version`
3. Optional version/hash refresh before first push:
   - `./scripts/update-package.sh`
4. Push to GitHub and enable Actions.
5. Add release notes describing:
   - upstream `pi-mono` version pin
   - current `src.hash`
   - current `npmDepsHash`

## Upstream Maintenance Loop

1. Update:
   - `./scripts/update-package.sh --version <new-version>`
2. Verify:
   - `nix flake check --all-systems`
   - `nix run .#pi-coding-agent -- --version`
3. Commit and tag release.
