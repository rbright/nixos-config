# `pi-coding-agent` Nix Package

Local standalone package definition for `pi` from
[`badlogic/pi-mono`](https://github.com/badlogic/pi-mono).

## Purpose

Keep a reproducible local package (`pi-coding-agent`) until upstream packaging is available in `nixpkgs`.

## Source of Truth

- Canonical derivation: `package.nix`
- Compatibility wrapper (`callPackage` stability): `default.nix`
- Standalone extraction flake: `flake.nix`
- Updater script: `scripts/update-package.sh`
- Extraction checklist: `EXTRACTION.md`

## Build and Run

From this directory (`pkgs/pi-coding-agent`):

```sh
nix build -L 'path:.#pi-coding-agent'
nix run 'path:.#pi-coding-agent' -- --help
```

Success looks like:

- build exits with code `0`
- run prints `pi` CLI usage/help output

## Update Workflow

From this directory:

```sh
./scripts/update-package.sh
./scripts/update-package.sh --version 0.53.0
```

What the updater changes in `package.nix`:

- `version`
- `src.hash`
- `npmDepsHash`

### Updater prerequisites

`./scripts/update-package.sh` requires:

- `curl`
- `jq`
- `nix`
- `npm`
- `perl`
- `tar`

Check usage:

```sh
./scripts/update-package.sh --help
```

### Post-update verification

```sh
nix build -L 'path:.#pi-coding-agent'
nix run 'path:.#pi-coding-agent' -- --version
```

Success looks like:

- package builds
- reported runtime version matches the updated `package.nix` version

## Extract to Standalone Repo

From monorepo root:

```sh
./pkgs/pi-coding-agent/scripts/scaffold-standalone.sh /tmp/pi-coding-agent-nix
```

Then follow `EXTRACTION.md`.

Check scaffold usage:

```sh
./pkgs/pi-coding-agent/scripts/scaffold-standalone.sh --help
```

## Troubleshooting

- **`update-package.sh` says missing command**
  - Install the missing prerequisite listed above.
- **Updater cannot find `package-lock.json` in source archive**
  - Verify upstream repo/tag still contains workspace lock data.
- **Build fails after update**
  - Re-run updater for the intended tag and confirm `src.hash`/`npmDepsHash` were updated together.

## Related Docs

- Root usage + host workflows: `../../README.md`
- Extraction guide: `./EXTRACTION.md`