# NixOS Configuration

This repository contains NixOS configuration files.

## Available Commands

### Bootstrap System

```sh
./bootstrap.zsh
```

This command initializes a new macOS system by:
- Installing Xcode CLI Tools
- Installing NixOS via the Determinate Systems installer

Note: This command should be run first on a new macOS system before other commands.

### Update Packages

```sh
nix flake update
```

This command updates the `flake.lock` file with the latest versions of all dependencies. This is useful when you want to:
- Update all packages to their latest versions from nixpkgs
- Get the latest updates from other flake inputs
- Update your system before rebuilding

### Build Configuration

```sh
nix run .#build
```

This command builds the NixOS configuration but does not apply it. This is useful for:
- Testing if your configuration builds successfully
- Reviewing what changes would be made
- Pre-building the configuration before switching to it

### Build and Switch

```sh
nix run .#build-switch
```

This command builds the configuration and then switches the system to use it. This will:
- Build the new configuration
- Apply all changes to your system
- Switch to the new configuration immediately

Note: The `build-switch` command requires appropriate permissions (usually root/sudo) to apply system changes.