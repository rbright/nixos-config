# Use bash with strict error checking
set shell := ["bash", "-uc"]

# Allow passing arguments to recipes
set positional-arguments

# Show available recipes with their descriptions
default:
    @just --list

# Bootstrap the local development environment
[group('bootstrap')]
bootstrap:
    ./scripts/bootstrap.zsh

# Update all nix flakes
[group('nix')]
update:
    nix flake update

# Update a specific nix flake
[group('nix')]
update-flake flake:
    nix flake update {{flake}}

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
