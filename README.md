# Nix Configuration

## Overview

This repository contains my Nix configuration for macOS.

## Available Tasks

All tasks can be run using `just <task>`. To see a list of available tasks, run `just`.

### Bootstrap System with Nix

```sh
just bootstrap
```

This task initializes a new macOS system by:

- Installing Xcode CLI Tools
- Installing Nix via the [Determinate Systems installer](https://determinate.systems/nix-installer/)

Note: This task should be run first on a new macOS system before other tasks.

### Update Nix Packages

```sh
just nix-update
```

This task updates `flake.lock` file with the latest versions of all dependencies. This is useful when you want to:

- Update all packages to their latest versions from [nixpkgs](https://search.nixos.org/packages)
- Get the latest updates from other flake inputs
- Update your system before rebuilding

### Build Configuration

```sh
just nix-build
```

This task builds the Nix configuration but does not apply it. This is useful for:

- Testing if your Nix configuration builds successfully
- Reviewing what changes would be made
- Pre-building the Nix configuration before switching to it

### Install Configuration

```sh
just nix-install
```

This task builds the Nix configuration and then switches the system to use it. This will:

- Build the new Nix configuration
- Apply all changes to your system
- Switch to the new Nix configuration immediately

Note: The `nix-install` tasks requires appropriate permissions (usually root/sudo) to apply system changes.

### Rollback Configuration

```sh
just nix-rollback
```

This task rolls back to a previous system configuration. Use this if you encounter issues with the current configuration.

### List Generations

```sh
just nix-list
```

This task lists all available system generations, showing when they were created and their status.

### Clean Old Generations

```sh
just nix-clean
```

This task cleans up old system generations to free up disk space. It requires sudo privileges to remove old generations.
