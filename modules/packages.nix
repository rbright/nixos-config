{ pkgs }:

with pkgs;
[
  # macOS
  aerospace
  dockutil
  mas

  # GPG
  gnupg
  gnutls
  pinentry_mac

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
  ripgrep
  starship
  stow
  tmux
  wget
  woff2
  yq
  zoxide

  # Text Editing
  hadolint
  neovim
  shellcheck
  tree-sitter

  # Development Tools
  just
  ngrok

  # Nix Development
  nil
  nixfmt-rfc-style

  # Nushell
  nushellPlugins.formats
  nushellPlugins.gstat
  nushellPlugins.net
  nushellPlugins.polars
  nushellPlugins.query
  nushellPlugins.units

  # Go Development
  go
  golangci-lint

  # Lua Development
  lua-language-server
  luajitPackages.luarocks

  # Node.js Development
  nodejs_22
  pnpm
  watchman

  # Python Development
  uv

  # Rust Development
  cargo
  rustc

  # Mobile Development
  android-tools
  cocoapods
  fastlane

  # Data Management
  atlas
  natscli

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
