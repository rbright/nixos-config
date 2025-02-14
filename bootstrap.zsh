#!/usr/bin/env zsh

print -P "%F{yellow}Initializing macOS bootstrap%f"

# Xcode CLI Tools
print -P "%F{blue}Installing Xcode CLI Tools%f"
xcode-select --install

# NixOS
print -P "%F{blue}Installing NixOS%f"
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

print -P "%F{yellow}Completed macOS bootstrap%f"