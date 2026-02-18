# pi-coding-agent Package Agent Guide

## Scope

These rules apply only under `pkgs/pi-coding-agent/`.

## Mission

Keep the local `pi-coding-agent` package update path reproducible and extraction-ready.

## Workflow Rules

| Scope | Problem | Rule | Why | Example | When to use | Benefits |
| --- | --- | --- | --- | --- | --- | --- |
| Component | Manual version/hash drift | Use scripted update flows instead of hand-editing hashes. | Package updates require coordinated version/hash refresh in one pass. | `just update-pi 0.53.0` or `./pkgs/pi-coding-agent/scripts/update-package.sh --version 0.53.0` | Updating upstream pi version | Repeatable updates with fewer hash mistakes |
| Component | Standalone extraction docs/tooling drift | Keep `README.md`, `EXTRACTION.md`, and `scripts/scaffold-standalone.sh` aligned when changing extraction behavior. | Extraction is intended to be copy-ready; stale docs/scripts break portability. | Update docs + scaffold script in same change. | Any change to extraction/export workflow | Reliable standalone handoff |
| Component | Broken package/runtime validation | Run targeted checks after package script or packaging changes. | Packaging issues are often shell/nix integration failures. | `bash -n scripts/update-package.sh`; `nix flake check path:.` | Edits to package.nix, updater scripts, scaffold, or flake files | Early detection of packaging regressions |

## Validation Baseline

- `just lint`
- `just build omega` (repo integration proof)
- Package-targeted checks relevant to touched files (for example `bash -n ...`, `nix flake check path:.`)

If any check is skipped, record why and the exact command to run.
