# Use bash with strict error checking

set shell := ["bash", "-uc"]

# Allow passing arguments to recipes

set positional-arguments := true

# Show available recipes with their descriptions
default:
    @just --list

# ------------------------------------------------------------------------------
# Defaults / inventory
# ------------------------------------------------------------------------------

default_host := "lambda"

# Bootstrap the local development environment
[group('bootstrap')]
bootstrap host=default_host:
    if [[ "{{ host }}" == "lambda" ]]; then \
      ./scripts/bootstrap.zsh; \
    elif [[ "{{ host }}" == "omega" ]]; then \
      curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install; \
    else \
      echo "Unknown host '{{ host }}' (expected: lambda|omega)" >&2; \
      exit 1; \
    fi

# ------------------------------------------------------------------------------
# Linting
# ------------------------------------------------------------------------------

# Format tracked Nix files (nixfmt; excludes hardware-configuration.nix)
[group('qa')]
fmt:
    nix develop -c bash -euo pipefail -c 'mapfile -t files < <(git ls-files "*.nix" | grep -v "hardware-configuration.nix$"); nixfmt "${files[@]}"'

# Check formatting only (no changes)
[group('qa')]
fmt-check:
    nix develop -c bash -euo pipefail -c 'mapfile -t files < <(git ls-files "*.nix" | grep -v "hardware-configuration.nix$"); nixfmt --check "${files[@]}"'

# Lint Nix configs (statix + deadnix + formatting check)
[group('qa')]
lint:
    nix develop -c statix check --ignore 'hosts/**/hardware-configuration.nix' .
    nix develop -c bash -euo pipefail -c 'mapfile -t files < <(git ls-files "*.nix" | grep -v "hardware-configuration.nix$"); deadnix --fail --no-underscore "${files[@]}"'
    nix develop -c bash -euo pipefail -c 'mapfile -t files < <(git ls-files "*.nix" | grep -v "hardware-configuration.nix$"); nixfmt --check "${files[@]}"'

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
build host=default_host:
    if [[ "{{ host }}" == "lambda" ]]; then \
      nix build .#darwinConfigurations.lambda.system; \
    elif [[ "{{ host }}" == "omega" ]]; then \
      nix build .#homeConfigurations.omega.activationPackage; \
    else \
      echo "Unknown host '{{ host }}' (expected: lambda|omega)" >&2; \
      exit 1; \
    fi

# Install nix configuration
[group('nix')]
install host=default_host:
    just switch {{ host }}

# Switch the active host configuration
[group('nix')]
switch host=default_host:
    if [[ "{{ host }}" == "lambda" ]]; then \
      rm -f ./result; \
      nix build .#darwinConfigurations.lambda.system && \
      sudo ./result/sw/bin/darwin-rebuild switch --flake .#lambda; \
      rm -f ./result; \
    elif [[ "{{ host }}" == "omega" ]]; then \
      rm -f ./result; \
      nix build .#homeConfigurations.omega.activationPackage && \
      ./result/activate; \
      rm -f ./result; \
    else \
      echo "Unknown host '{{ host }}' (expected: lambda|omega)" >&2; \
      exit 1; \
    fi

# Rollback to a previous generation
[group('nix')]
rollback host=default_host generation="":
    if [[ "{{ host }}" == "lambda" ]]; then \
      sudo /run/current-system/sw/bin/darwin-rebuild --list-generations; \
      if [[ -z "{{ generation }}" ]]; then \
        echo "Pass a generation number, e.g. 'just rollback lambda 123'"; \
        exit 1; \
      fi; \
      sudo /run/current-system/sw/bin/darwin-rebuild switch --flake .#lambda --switch-generation "{{ generation }}"; \
    elif [[ "{{ host }}" == "omega" ]]; then \
      home-manager generations; \
      if [[ -z "{{ generation }}" ]]; then \
        echo "Pass a generation path, e.g. 'just rollback omega /nix/store/...-home-manager-generation'"; \
        exit 1; \
      fi; \
      "{{ generation }}"/activate; \
    else \
      echo "Unknown host '{{ host }}' (expected: lambda|omega)" >&2; \
      exit 1; \
    fi

# List generations
[group('nix')]
list host=default_host:
    if [[ "{{ host }}" == "lambda" ]]; then \
      sudo /run/current-system/sw/bin/darwin-rebuild --list-generations; \
    elif [[ "{{ host }}" == "omega" ]]; then \
      home-manager generations; \
    else \
      echo "Unknown host '{{ host }}' (expected: lambda|omega)" >&2; \
      exit 1; \
    fi

# Clean up old generations
[group('nix')]
clean:
    sudo nix-collect-garbage --delete-old
