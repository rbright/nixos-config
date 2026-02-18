#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
package_root="$(cd -- "${script_dir}/.." && pwd)"

usage() {
  cat <<'EOF'
Usage:
  pkgs/pi-coding-agent/scripts/scaffold-standalone.sh [--force] <target-dir>

Examples:
  pkgs/pi-coding-agent/scripts/scaffold-standalone.sh /tmp/pi-coding-agent-nix
  pkgs/pi-coding-agent/scripts/scaffold-standalone.sh --force ~/Projects/pi-coding-agent-nix
EOF
}

force="false"
target_dir=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force)
      force="true"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      if [[ -n "$target_dir" ]]; then
        echo "Unexpected argument: $1" >&2
        usage >&2
        exit 1
      fi
      target_dir="$1"
      shift
      ;;
  esac
done

if [[ -z "$target_dir" ]]; then
  usage >&2
  exit 1
fi

if [[ -d "$target_dir" && -n "$(ls -A "$target_dir" 2>/dev/null)" && "$force" != "true" ]]; then
  echo "Target directory is not empty: $target_dir" >&2
  echo "Use --force to overwrite files in place." >&2
  exit 1
fi

mkdir -p "$target_dir/scripts" "$target_dir/.github/workflows"

cp "$package_root/package.nix" "$target_dir/package.nix"
cp "$package_root/default.nix" "$target_dir/default.nix"
cp "$package_root/flake.nix" "$target_dir/flake.nix"
cp "$package_root/flake.lock" "$target_dir/flake.lock"
cp "$package_root/README.md" "$target_dir/README.md"
cp "$package_root/scripts/update-package.sh" "$target_dir/scripts/update-package.sh"
chmod +x "$target_dir/scripts/update-package.sh"

cat >"$target_dir/.gitignore" <<'EOF'
result
.direnv
EOF

cat >"$target_dir/justfile" <<'EOF'
set shell := ["bash", "-uc"]
set positional-arguments := true

default:
    @just --list

build:
    nix build -L .#pi-coding-agent

run *args='--help':
    nix run .#pi-coding-agent -- {{ args }}

update version="":
    if [[ -n "{{ version }}" ]]; then \
      ./scripts/update-package.sh --version "{{ version }}"; \
    else \
      ./scripts/update-package.sh; \
    fi

check:
    nix flake check --all-systems
EOF

cat >"$target_dir/.github/workflows/ci.yml" <<'EOF'
name: ci

on:
  push:
  pull_request:

jobs:
  flake-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: cachix/install-nix-action@v31
      - run: nix flake check --all-systems
EOF

echo "Standalone scaffold created at: $target_dir"
echo "Next steps:"
echo "  cd $target_dir"
echo "  nix flake check --all-systems"
echo "  nix run .#pi-coding-agent -- --version"
