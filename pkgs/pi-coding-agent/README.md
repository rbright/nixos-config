# `pi-coding-agent` Nix Package

Local standalone package definition for `pi` from
[`badlogic/pi-mono`](https://github.com/badlogic/pi-mono).

## Layout

- `package.nix`: canonical derivation.
- `default.nix`: compatibility wrapper (`import ./package.nix`), so existing
  `pkgs.callPackage ../../pkgs/pi-coding-agent { }` call sites keep working.
- `flake.nix`: standalone mini-flake for extraction/publishing.
- `scripts/update-package.sh`: helper to bump version + hashes.
- `scripts/scaffold-standalone.sh`: export this package as a standalone repo skeleton.
- `EXTRACTION.md`: extraction and publish checklist.

## Build And Run

From this directory:

```sh
nix build -L 'path:.#pi-coding-agent'
nix run 'path:.#pi-coding-agent' -- --help
```

## Update Workflow

From this directory:

```sh
./scripts/update-package.sh
./scripts/update-package.sh --version 0.53.0
```

The script updates:

- `version`
- `src.hash`
- `npmDepsHash`

in `package.nix`.

## Extract To Standalone Repo

From monorepo root:

```sh
./pkgs/pi-coding-agent/scripts/scaffold-standalone.sh /tmp/pi-coding-agent-nix
```

Then follow `EXTRACTION.md`.
