{ pkgs }:

with pkgs;
[
  # macOS
  aerospace
  dockutil
  mas
  sketchybar
  skhd

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
  htop
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
  xh
  xz
  zoxide

  # Text Editing
  hadolint
  neovim
  shellcheck
  tree-sitter

  # Development Tools
  auth0-cli
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
  stylua

  # Node.js Development
  nodejs_22
  pnpm
  watchman

  # Python Development
  ruff
  uv

  # Rust Development
  cargo
  rustc

  # SQL Development
  sqlfluff

  # TypeScript Development
  eslint_d
  prettierd

  # Mobile Development
  android-tools
  cocoapods
  fastlane

  # Data Management
  atlas
  natscli
  postgresql

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

  # IT Automation
  ansible
  ansible-lint
]
