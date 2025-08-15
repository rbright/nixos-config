{
  pkgs,
  ...
}:

with pkgs;
[
  ##############################################################################
  # Core
  ##############################################################################

  # GPG
  gnupg # GNU Privacy Guard for encryption and signing
  gnutls # GNU Transport Layer Security library

  # Git
  gh # GitHub CLI tool
  git # Distributed version control system
  git-lfs # Git Large File Storage extension
  graphite-cli # Stacked diffs workflow for Git

  # Terminal
  atuin # Shell history management tool
  bat # Cat clone with syntax highlighting
  btop # Resource monitor with modern interface
  carapace # Multi-shell completion framework
  direnv # Environment variable management per directory
  eza # Modern replacement for ls
  fd # Fast and user-friendly alternative to find
  fzf # Command-line fuzzy finder
  htop # Interactive process viewer
  jq # JSON processor and query tool
  just # Command runner and build tool
  mkcert # Local HTTPS certificate generator
  nushell # Modern shell with structured data
  ripgrep # Fast text search tool (grep alternative)
  starship # Cross-shell customizable prompt
  stow # Symlink farm manager for dotfiles
  tmux # Terminal multiplexer
  wget # Network downloader
  woff2 # Web font compression utilities
  yq # YAML processor (jq for YAML)
  xh # HTTP client (curl/HTTPie alternative)
  xz # Compression utilities
  zoxide # Smart cd command with frecency algorithm

  ##############################################################################
  # Software Development
  ##############################################################################

  # AI Assistants
  opencode # AI-powered coding assistant

  # Text Editing
  hadolint # Dockerfile linter
  neovim # Modern Vim-based text editor
  shellcheck # Shell script static analysis tool
  tree-sitter # Parsing framework for syntax highlighting

  # Go
  go # Go programming language compiler and tools
  golangci-lint # Fast Go linters runner

  # Lua
  lua-language-server # Language server for Lua
  luajitPackages.luarocks # Package manager for Lua
  stylua # Lua code formatter

  # Nix
  deploy-rs # NixOS deployment tool
  nil # Nix language server
  nixfmt-rfc-style # Nix code formatter following RFC style

  # Nushell
  nushellPlugins.formats # Data format conversion plugin
  nushellPlugins.gstat # Git statistics plugin
  nushellPlugins.polars # DataFrame processing plugin
  nushellPlugins.query # Web scraping and querying plugin
  nushellPlugins.units # Unit conversion plugin

  # TODO: Marked as broken as of 2025-07-05
  # https://github.com/NixOS/nixpkgs/pull/421135
  # nushellPlugins.net # Network utilities plugin

  # Node.js
  bun # Fast, disk space efficient package manager
  nodejs_22 # Node.js JavaScript runtime (version 22)
  pnpm # Fast, disk space efficient package manager
  watchman # File watching service for development

  # Python
  ruff # Fast Python linter and formatter

  # Rust
  cargo # Rust package manager and build system
  rustc # Rust programming language compiler

  # SQL
  sqlfluff # SQL linter and formatter

  # TypeScript
  eslint_d # ESLint daemon for faster linting
  prettierd # Prettier daemon for faster code formatting

  ##############################################################################
  # Machine Learning
  ##############################################################################

  ollama # LLM runtime

  ##############################################################################
  # Development Tools
  ##############################################################################

  # Web Application
  auth0-cli # Command-line tool for Auth0 identity platform
  ngrok # Secure tunnels to localhost for development

  # Mobile Application
  android-tools # Android SDK platform tools (adb, fastboot)
  cocoapods # Dependency manager for Swift and Objective-C
  fastlane # Mobile app automation and deployment

  # Data
  atlas # Database schema migration tool
  postgresql # Object-relational database system

  # Messaging
  natscli # Command-line client for NATS messaging system

  ##############################################################################
  # Infrastructure
  ##############################################################################

  # Cloud
  google-cloud-sdk # Google Cloud Platform command-line tools
  opentofu # Open-source Terraform alternative
  pulumi # Infrastructure as Code with multiple languages
  terraform # Infrastructure as Code tool

  # Containerization
  docker # Containerization platform desktop app

  # Kubernetes
  chart-testing # Helm chart testing tool
  helmfile # Declarative spec for deploying Helm charts
  k3d # Lightweight Kubernetes cluster manager
  kubectl # Kubernetes command-line tool
  kubernetes-helm # Kubernetes package manager
  kubeseal # Kubernetes controller and tool for one-way encrypted Secrets
  tilt # Multi-service development environment
]
