# NixOS Configuration

This repository contains NixOS configuration files.

## Available Commands

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