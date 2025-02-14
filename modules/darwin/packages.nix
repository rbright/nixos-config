{ pkgs }:

with pkgs;
let shared-packages = import ../shared/packages.nix { inherit pkgs; }; in
shared-packages ++ [
  # Terminal
  btop
  dockutil
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

  # Text Editing
  hadolint
  neovim
  shellcheck

  # GPG
  gnupg
  gnutls
  pinentry_mac

  # Language Tools
  go
  watchman
  ngrok

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

  # Data Management
  atlas
  natscli

  # Mobile Development
  cocoapods
  fastlane
]
