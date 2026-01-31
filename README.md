# Nix + macOS Configuration

A comprehensive, declarative macOS configuration using [Nix](https://nixos.org/) flakes, [nix-darwin](https://github.com/LnL7/nix-darwin), and [home-manager](https://github.com/nix-community/home-manager). This configuration provides a reproducible development environment with carefully tuned system preferences, package management, and application settings.

## 🏗️ Architecture

This configuration uses a modular architecture combining:
- **[Nix](https://nixos.org/) Flakes** for reproducible builds and dependency management
- **[nix-darwin](https://github.com/LnL7/nix-darwin)** for macOS system configuration
- **[home-manager](https://github.com/nix-community/home-manager)** for user-level packages and dotfiles
- **[nix-homebrew](https://github.com/zhaofengli/nix-homebrew)** for declarative Homebrew management

## 💡 Key Features

- **Fully Reproducible Environment** - Every setting, package, and preference is declared in code and version-controlled
- **Zero-Configuration Setup** - Clone and run a single command to get a complete development environment
- **Atomic System Updates** - Build and test changes before applying, with instant rollback capability
- **Hybrid Package Management** - Combines Nix's reproducibility with Homebrew's macOS app ecosystem
- **Infrastructure-as-Code** - Complete macOS system configuration managed through Nix modules

## 🚀 Getting Started

### Initial Setup
1. **Install Nix** (if not already installed):
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```

2. **Clone and bootstrap**:
   ```bash
   git clone <this-repo>
   cd nixos-config
   just bootstrap
   ```

3. **Build and install**:
   ```bash
   just install
   ```

### Daily Usage
- **Update system**: `just update && just install`
- **Install new software**: Add to appropriate package list and run `just install`
- **Rollback changes**: `just rollback`
- **Clean old generations**: `just clean`

## 🛠️ Commands

All common operations are available through the `just` task runner:

### Bootstrap & Setup
```bash
just bootstrap          # Bootstrap new macOS installation
```
Runs `./scripts/bootstrap.zsh` to install Xcode CLI tools and Nix.

### System Management
```bash
just build              # Build configuration without applying
just install            # Build and switch to new configuration
just rollback           # Rollback to previous generation
just list               # List all system generations
```

### Maintenance
```bash
just update             # Update all flake inputs
just update-flake FLAKE # Update specific flake input
just clean              # Clean up old generations
```

### Quality
```bash
just fmt                # Format tracked Nix files (Alejandra)
just fmt-check          # Verify formatting
just lint               # statix + deadnix + formatting check
```

### Development
```bash
just                    # Show all available commands
```

## 🔧 Customization

### Adding Packages
- **CLI tools**: Add to `modules/packages.nix`
- **GUI apps**: Add to `modules/darwin/homebrew/casks.nix`
- **Homebrew formulas**: Add to `modules/darwin/homebrew/brews.nix`
- **Mac App Store**: Add to homebrew `masApps` list

### Modifying System Preferences
- Edit relevant files in `modules/darwin/`
- Each module handles specific system aspects (keyboard, finder, dock, etc.)
- Run `just install` to apply changes

### Custom Applications
- Add dock entries in `modules/darwin/dock/default.nix`
- Configure app-specific preferences in `modules/darwin/applications/`

## 📦 Package Management

This configuration uses a hybrid approach with four package managers:

- **[Nix Packages](./modules/packages.nix)** - CLI tools, development dependencies, and system utilities
- **[Homebrew Casks](./modules/darwin/homebrew/casks.nix)** - GUI applications and macOS-specific software
- **[Homebrew Brews](./modules/darwin/homebrew/brews.nix)** - Additional CLI tools not available in Nix
- **[Mac App Store Apps](./modules/darwin/homebrew/default.nix)** - Apps distributed through Apple's store

Each package manager handles what it does best: Nix for reproducible development tools, Homebrew for macOS applications, and the Mac App Store for Apple ecosystem integration.

## 🔐 Security Features

- **Firewall enabled** with stealth mode
- **Secure DNS** (Cloudflare 1.1.1.1)
- **GPG integration** with pinentry for macOS
- **No .DS_Store files** on network/USB drives
- **Quarantine disabled** for trusted applications
- **Auto-updates** for critical security patches

## 📁 Directory Structure

```sh
nixos-config/
├── flake.nix              # Main flake configuration
├── flake.lock             # Pinned dependency versions
├── justfile               # Task runner commands
├── bootstrap.zsh          # Initial setup script
├── hosts/darwin/          # Host-specific configuration
├── modules/
│   ├── darwin/            # macOS system modules
│   │   ├── applications/  # App-specific preferences
│   │   ├── dock/          # Custom dock management
│   │   └── homebrew/      # Homebrew package lists
│   ├── packages.nix       # Nix package definitions
│   └── home-manager.nix   # User-level configuration
└── apps/                  # System management scripts
```

## 📋 Components

| Component | Description | Location |
|-----------|-------------|----------|
| [**Flake Configuration**](./flake.nix) | Main entry point defining inputs, outputs, and system configuration | `flake.nix` |
| [**Darwin Host**](./hosts/darwin/) | macOS system-level configuration and module imports | `hosts/darwin/` |
| [**Darwin Modules**](./modules/darwin/) | Modular macOS system preferences and application settings | `modules/darwin/` |
| [**Package Management**](./modules/packages.nix) | Comprehensive package list | `modules/packages.nix` |
| [**Home Manager**](./modules/home-manager.nix) | User-level package management and service configuration | `modules/home-manager.nix` |
| [**Homebrew Integration**](./modules/darwin/homebrew/) | Declarative Homebrew casks, brews, and Mac App Store apps | `modules/darwin/homebrew/` |
| [**Applications**](./apps/) | System management scripts (build, install, rollback) | `apps/` |
| [**Bootstrap Script**](./bootstrap.zsh) | Initial system setup script for new macOS installations | `bootstrap.zsh` |
| [**Task Runner**](./justfile) | Just commands for common operations | `justfile` |

### Darwin System Modules

| Module | Description | Location |
|--------|-------------|----------|
| [**Applications**](./modules/darwin/applications/) | App-specific preferences (Activity Monitor, Spotlight, etc.) | `modules/darwin/applications/` |
| [**Dock**](./modules/darwin/dock/) | Custom declarative dock management with dockutil | `modules/darwin/dock/` |
| [**Finder**](./modules/darwin/finder.nix) | Finder preferences and file management settings | `modules/darwin/finder.nix` |
| [**Keyboard**](./modules/darwin/keyboard.nix) | Keyboard behavior and shortcuts | `modules/darwin/keyboard.nix` |
| [**Networking**](./modules/darwin/networking.nix) | Network configuration, DNS, and firewall settings | `modules/darwin/networking.nix` |
| [**Desktop**](./modules/darwin/desktop.nix) | Window management and desktop behavior | `modules/darwin/desktop.nix` |
| [**System Preferences**](./modules/darwin/) | Complete macOS system preferences coverage | `modules/darwin/*.nix` |

## 📖 Resources

- [Nix Darwin Documentation](https://github.com/LnL7/nix-darwin)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)
- [macOS System Preferences](https://macos-defaults.com/)
