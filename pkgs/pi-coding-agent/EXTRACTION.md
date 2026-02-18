# Standalone Extraction Guide

Use this guide when publishing `pkgs/pi-coding-agent` as its own repository.

## Purpose

Create a standalone package repo that stays aligned with the monorepo package source of truth (`package.nix` + update script).

## Fast Path

From monorepo root:

```sh
./pkgs/pi-coding-agent/scripts/scaffold-standalone.sh /tmp/pi-coding-agent-nix
```

Success looks like a scaffolded directory containing:

- package files: `package.nix`, `default.nix`, `flake.nix`, `flake.lock`
- updater: `scripts/update-package.sh`
- docs: `README.md`
- repo scaffolding: `.gitignore`, `justfile`, `.github/workflows/ci.yml`

## Publish Checklist

1. Initialize repository:

   ```sh
   cd /tmp/pi-coding-agent-nix
   git init
   ```

2. Validate locally:

   ```sh
   nix flake check --all-systems
   nix build -L .#pi-coding-agent
   nix run .#pi-coding-agent -- --version
   ```

3. (Optional) Refresh version/hashes before first push:

   ```sh
   ./scripts/update-package.sh
   ```

4. Push to GitHub and enable Actions.
5. Add release notes with:
   - upstream `pi-mono` version pin
   - `src.hash`
   - `npmDepsHash`

## Ongoing Maintenance Loop

1. Update:

   ```sh
   ./scripts/update-package.sh --version <new-version>
   ```

2. Verify:

   ```sh
   nix flake check --all-systems
   nix run .#pi-coding-agent -- --version
   ```

3. Commit and tag release.

## Troubleshooting

- **Scaffold target exists and is not empty**
  - Re-run with `--force` if overwrite is intentional:
    ```sh
    ./pkgs/pi-coding-agent/scripts/scaffold-standalone.sh --force /tmp/pi-coding-agent-nix
    ```
- **`nix flake check --all-systems` is too heavy locally**
  - Run at least:
    ```sh
    nix build -L .#pi-coding-agent
    nix run .#pi-coding-agent -- --version
    ```
  - Then rely on CI for full matrix verification.

## Related Docs

- Component overview: `./README.md`
- Monorepo entrypoint: `../../README.md`