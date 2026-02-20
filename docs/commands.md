# Command Reference (`justfile`)

This is the human-readable guide for root-level commands. The authoritative implementation is the [`justfile`](../justfile).

## Conventions

- `<host>` is `lambda` or `omega`.
- Omit `<host>` to use the default host (`lambda`).
- Run `just --list` to view grouped recipes and descriptions.

## Bootstrap

### `just bootstrap <host>`

Initial machine setup.

- `lambda`: runs `scripts/bootstrap.zsh` (Xcode CLI tools + Nix installer).
- `omega`: prints that bootstrap is not required.

Success looks like:

- Command exits `0`.
- On `lambda`, bootstrap script prints completion message.

## QA Commands

### `just fmt`

Formats tracked `*.nix` files (except `hardware-configuration.nix`).

### `just fmt-check`

Checks formatting only (no edits).

### `just lint`

Runs:

1. `statix check`
2. `deadnix --fail --no-underscore`
3. `nixfmt --check`

Success looks like: all tools exit `0`.

### `just hypr-smoke`

Runs runtime Hyprland checks via `scripts/hypr-smoke-test.sh`.

Success looks like:

- Script prints pass summary.
- Exit code is `0`.

> Requires a live Hyprland session.

## Host Lifecycle Commands

### Build

```sh
just build <host>
```

- `lambda`: builds `darwinConfigurations.lambda.system`
- `omega`: builds `nixosConfigurations.omega.config.system.build.toplevel`

Success looks like: build exits `0` and updates `./result` symlink when applicable.

### Switch (activate)

```sh
just switch <host>
```

- `lambda`: builds then runs `darwin-rebuild switch`.
- `omega`: runs `nixos-rebuild switch`.

Success looks like: active system generation changes without evaluation/runtime errors.

### Install alias

```sh
just install <host>
```

Alias for `just switch <host>`.

### Update lock file for one host

```sh
just update <host>
```

Runs `nix flake update` for the selected host flake only.

### Update one flake input

```sh
just update-flake <input> <host>
```

Example:

```sh
just update-flake nixpkgs omega
```

### List generations

```sh
just list <host>
```

Shows available system generations.

### Roll back generation

```sh
just rollback <host> <generation>
```

Switches to a specific existing generation.

### Clean old generations

```sh
just clean <host> [older_than]
```

Default `older_than` is `30d`.

- `lambda`: garbage-collects old generations.
- `omega`: deletes old system generations, rebuilds boot entries, then garbage-collects.

## Practical Workflow Shortcuts

### Fast validation loop (omega)

```sh
just lint
just build omega
```

### Host update flow

```sh
just update omega
just build omega
just switch omega
```

### Safer rollback flow

```sh
just list omega
just rollback omega <generation>
```
