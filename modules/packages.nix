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
  fish
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

  # Development Tools
  android-tools
  atlas
  cocoapods
  fastlane
  go
  golangci-lint
  hadolint
  just
  natscli
  neovim
  ngrok
  nil
  nixfmt-rfc-style
  pnpm
  podman
  shellcheck
  uv
  watchman

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
