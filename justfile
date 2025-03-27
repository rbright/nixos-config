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
    ./bootstrap.zsh

# Update nix flake
[group('nix')]
flake-update:
    nix flake update

# Build nix configuration
[group('nix')]
nix-build:
    nix run .#build

# Install nix configuration
[group('nix')]
nix-install:
    nix run .#build-switch

# Rollback to a previous generation
[group('nix')]
nix-rollback:
    nix run .#rollback

# List old generations
[group('nix')]
nix-list:
    nix-env --list-generations

# Clean up old generations
[group('nix')]
nix-clean:
    sudo nix-collect-garbage --delete-old
