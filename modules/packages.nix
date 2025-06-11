{
  pkgs,
  ...
}:

with pkgs;
[
  ##############################################################################
  # Core
  ##############################################################################

  # macOS
  aerospace
  dockutil
  espanso
  ice-bar
  mas
  skhd

  # GPG
  gnupg
  gnutls
  pinentry_mac

  # Git
  gh
  git
  git-lfs
  graphite-cli

  # Terminal
  btop
  carapace
  direnv
  fd
  fzf
  htop
  jq
  just
  mkcert
  nushell
  ripgrep
  starship
  stow
  tmux
  wget
  woff2
  yq
  xh
  xz
  zoxide

  ##############################################################################
  # Software Development
  ##############################################################################

  # Text Editing
  hadolint
  neovim
  shellcheck
  tree-sitter

  # Go
  go
  golangci-lint

  # Lua
  lua-language-server
  luajitPackages.luarocks
  stylua

  # Nix
  nil
  nixfmt-rfc-style

  # Nushell
  nushellPlugins.formats
  nushellPlugins.gstat
  nushellPlugins.net
  nushellPlugins.polars
  nushellPlugins.query
  nushellPlugins.units

  # Node.js
  nodejs_22
  pnpm
  watchman

  # Python
  ruff

  # Rust
  cargo
  rustc

  # SQL
  sqlfluff

  # TypeScript
  eslint_d
  prettierd

  ##############################################################################
  # Development Tools
  ##############################################################################

  # Web Application
  auth0-cli
  ngrok

  # Mobile Application
  android-tools
  cocoapods
  fastlane

  # Data
  atlas
  postgresql

  # Messaging
  natscli

  ##############################################################################
  # Infrastructure
  ##############################################################################

  # Cloud
  terraform
  opentofu
  google-cloud-sdk

  # Kubernetes
  k3d
  kubectl
  kubernetes-helm
  chart-testing
  tilt

  # Automation
  ansible
  ansible-lint
]
