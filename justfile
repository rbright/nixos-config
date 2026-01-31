# Use bash with strict error checking

set shell := ["bash", "-uc"]

# Allow passing arguments to recipes

set positional-arguments := true

# Show available recipes with their descriptions
default:
    @just --list

# Bootstrap the local development environment
[group('bootstrap')]
bootstrap:
    ./scripts/bootstrap.zsh

# ------------------------------------------------------------------------------
# Linting
# ------------------------------------------------------------------------------

# Format tracked Nix files (Alejandra; excludes hardware-configuration.nix)
[group('qa')]
fmt:
    nix develop -c bash -euo pipefail -c 'mapfile -t files < <(git ls-files "*.nix" | grep -v "hardware-configuration.nix$"); alejandra "${files[@]}"'

# Check formatting only (no changes)
[group('qa')]
fmt-check:
    nix develop -c bash -euo pipefail -c 'mapfile -t files < <(git ls-files "*.nix" | grep -v "hardware-configuration.nix$"); alejandra --check "${files[@]}"'

# Lint Nix configs (statix + deadnix + formatting check)
[group('qa')]
lint:
    nix develop -c statix check --ignore 'hosts/**/hardware-configuration.nix' .
    nix develop -c bash -euo pipefail -c 'mapfile -t files < <(git ls-files "*.nix" | grep -v "hardware-configuration.nix$"); deadnix --fail --no-underscore "${files[@]}"'
    nix develop -c bash -euo pipefail -c 'mapfile -t files < <(git ls-files "*.nix" | grep -v "hardware-configuration.nix$"); alejandra --check "${files[@]}"'

# ------------------------------------------------------------------------------
# Flake
# ------------------------------------------------------------------------------

# Update all nix flakes
[group('nix')]
update:
    nix flake update

# Update a specific nix flake
[group('nix')]
update-flake flake:
    nix flake update {{ flake }}

# ------------------------------------------------------------------------------
# Build
# ------------------------------------------------------------------------------

# Build nix configuration
[group('nix')]
build:
    nix run .#build

# Install nix configuration
[group('nix')]
install:
    nix run .#build-switch

# Rollback to a previous generation
[group('nix')]
rollback:
    nix run .#rollback

# List old generations
[group('nix')]
list:
    nix-env --list-generations

# Clean up old generations
[group('nix')]
clean:
    sudo nix-collect-garbage --delete-old
