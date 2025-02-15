{ pkgs }:

with pkgs;
[
  # macOS
  dockutil
  mas

  # Terminal
  btop
  carapace
  direnv
  fd
  fzf
  gh
  git
  git-lfs
  jq
  mkcert
  nushell
  starship
  stow
  wget
  woff2
  yq
  zoxide

  # GPG
  gnupg
  gnutls
  pinentry_mac

  # Text Editing
  neovim
  shellcheck

  # Development Tools
  just
  ngrok

  # Nix Development
  nil
  nixfmt-rfc-style

  # Go Development
  go
  golangci-lint

  # Lua Development
  luajitPackages.luarocks

  # Node.js Development
  nodejs_22
  pnpm
  watchman

  # Python Development
  uv

  # Mobile Development
  android-tools
  cocoapods
  fastlane

  # Data Management
  atlas
  natscli

  # Containers
  hadolint

  # Kubernetes
  kubectl
  k3d
  kubernetes-helm
  chart-testing
  tilt

  # Cloud Infrastructure
  opentofu
  terraform
  awscli2
  google-cloud-sdk
]
