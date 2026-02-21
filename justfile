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
macos_flake := "path:.?dir=hosts/lambda"
nixos_flake := "path:.?dir=hosts/omega"
nixos_sudo := "/run/wrappers/bin/sudo"
tooling_flake := `if [[ "$(uname -s)" == "Darwin" ]]; then echo "path:.?dir=hosts/lambda"; else echo "path:.?dir=hosts/omega"; fi`

# Bootstrap the local development environment
[group('bootstrap')]
bootstrap host=default_host:
    if [[ "{{ host }}" == "lambda" ]]; then \
      ./scripts/bootstrap.zsh; \
    elif [[ "{{ host }}" == "omega" ]]; then \
      echo "omega is NixOS; bootstrap not required."; \
    else \
      echo "Unknown host '{{ host }}' (expected: lambda|omega)" >&2; \
      exit 1; \
    fi

# ------------------------------------------------------------------------------
# QA / Linting
# ------------------------------------------------------------------------------

# Format tracked Nix files (nixfmt; excludes hardware-configuration.nix)
[group('qa')]
fmt:
    nix develop '{{ tooling_flake }}' -c bash -euo pipefail -c 'mapfile -t files < <(rg --files -g "*.nix" | grep -v "hardware-configuration.nix$"); nixfmt "${files[@]}"'

# Check formatting only (no changes)
[group('qa')]
fmt-check:
    nix develop '{{ tooling_flake }}' -c bash -euo pipefail -c 'mapfile -t files < <(rg --files -g "*.nix" | grep -v "hardware-configuration.nix$"); nixfmt --check "${files[@]}"'

# Lint Nix configs (statix + deadnix + formatting check)
[group('qa')]
lint:
    nix develop '{{ tooling_flake }}' -c statix check --ignore '**/hardware-configuration.nix' .
    nix develop '{{ tooling_flake }}' -c bash -euo pipefail -c 'mapfile -t files < <(rg --files -g "*.nix" | grep -v "hardware-configuration.nix$"); deadnix --fail --no-underscore "${files[@]}"'
    nix develop '{{ tooling_flake }}' -c bash -euo pipefail -c 'mapfile -t files < <(rg --files -g "*.nix" | grep -v "hardware-configuration.nix$"); nixfmt --check "${files[@]}"'

# Run runtime Hyprland smoke test for keymaps, binds, and workspace rules
[group('qa')]
hypr-smoke:
    bash ./scripts/hypr-smoke-test.sh

# List Vicinae application entrypoint IDs (optionally filtered by a search term)
[group('desktop')]
vicinae-apps search="":
    bash ./scripts/vicinae-apps.sh "{{ search }}"

# ------------------------------------------------------------------------------
# Flake
# ------------------------------------------------------------------------------

# Update lock data for one host only
[group('nix')]
update host=default_host:
    if [[ "{{ host }}" == "lambda" ]]; then \
      nix flake update --flake '{{ macos_flake }}'; \
    elif [[ "{{ host }}" == "omega" ]]; then \
      nix flake update --flake '{{ nixos_flake }}'; \
    else \
      echo "Unknown host '{{ host }}' (expected: lambda|omega)" >&2; \
      exit 1; \
    fi

# Update a specific input for one host (e.g. nixpkgs, home-manager)
[group('nix')]
update-flake flake host=default_host:
    if [[ "{{ host }}" == "lambda" ]]; then \
      nix flake update {{ flake }} --flake '{{ macos_flake }}'; \
    elif [[ "{{ host }}" == "omega" ]]; then \
      nix flake update {{ flake }} --flake '{{ nixos_flake }}'; \
    else \
      echo "Unknown host '{{ host }}' (expected: lambda|omega)" >&2; \
      exit 1; \
    fi

# ------------------------------------------------------------------------------
# Build
# ------------------------------------------------------------------------------

# Build nix configuration
[group('nix')]
build host=default_host:
    if [[ "{{ host }}" == "lambda" ]]; then \
      nix build '{{ macos_flake }}#darwinConfigurations.lambda.system'; \
    elif [[ "{{ host }}" == "omega" ]]; then \
      nix build '{{ nixos_flake }}#nixosConfigurations.omega.config.system.build.toplevel'; \
    else \
      echo "Unknown host '{{ host }}' (expected: lambda|omega)" >&2; \
      exit 1; \
    fi

# Install nix configuration
[group('nix')]
install host=default_host:
    @just switch {{ host }}

# Switch the active host configuration
[group('nix')]
switch host=default_host:
    @if [[ "{{ host }}" == "lambda" ]]; then \
      rm -f ./result; \
      nix build '{{ macos_flake }}#darwinConfigurations.lambda.system' && \
      sudo ./result/sw/bin/darwin-rebuild switch --flake '{{ macos_flake }}#lambda'; \
      rm -f ./result; \
    elif [[ "{{ host }}" == "omega" ]]; then \
      {{ nixos_sudo }} nixos-rebuild switch --flake '{{ nixos_flake }}#omega'; \
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
      sudo /run/current-system/sw/bin/darwin-rebuild switch --flake '{{ macos_flake }}#lambda' --switch-generation "{{ generation }}"; \
    elif [[ "{{ host }}" == "omega" ]]; then \
      {{ nixos_sudo }} nix-env --list-generations --profile /nix/var/nix/profiles/system; \
      if [[ -z "{{ generation }}" ]]; then \
        echo "Pass a generation number, e.g. 'just rollback omega 123'"; \
        exit 1; \
      fi; \
      {{ nixos_sudo }} nix-env --switch-generation "{{ generation }}" --profile /nix/var/nix/profiles/system; \
      {{ nixos_sudo }} /nix/var/nix/profiles/system/bin/switch-to-configuration switch; \
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
      {{ nixos_sudo }} nix-env --list-generations --profile /nix/var/nix/profiles/system; \
    else \
      echo "Unknown host '{{ host }}' (expected: lambda|omega)" >&2; \
      exit 1; \
    fi

# Clean up old generations for a specific host profile
[group('nix')]
clean host=default_host older_than="30d":
    if [[ "{{ host }}" == "lambda" ]]; then \
      sudo nix-collect-garbage --delete-older-than "{{ older_than }}"; \
    elif [[ "{{ host }}" == "omega" ]]; then \
      {{ nixos_sudo }} nix-env --delete-generations "{{ older_than }}" --profile /nix/var/nix/profiles/system; \
      {{ nixos_sudo }} nixos-rebuild boot --flake '{{ nixos_flake }}#omega'; \
      {{ nixos_sudo }} nix-collect-garbage --delete-older-than "{{ older_than }}"; \
    else \
      echo "Unknown host '{{ host }}' (expected: lambda|omega)" >&2; \
      exit 1; \
    fi
