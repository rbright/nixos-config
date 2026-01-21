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

  # Shell
  atuin # Shell history management tool
  bat # Cat clone with syntax highlighting
  carapace # Multi-shell completion framework
  eza # Modern replacement for ls
  fd # Fast and user-friendly alternative to find
  fzf # Command-line fuzzy finder
  nushell # Modern shell with structured data
  ripgrep # Fast text search tool (grep alternative)
  starship # Cross-shell customizable prompt
  tmux # Terminal multiplexer
  zoxide # Smart cd command with frecency algorithm

  # Utilities
  cloc # Count lines of code
  stow # Symlink farm manager for dotfiles
  wget # Network downloader
  woff2 # Web font compression utilities
  xh # HTTP client (curl/HTTPie alternative)
  xz # Compression utilities

  ##############################################################################
  # Software Development
  ##############################################################################

  # Git
  gh # GitHub CLI tool
  git # Distributed version control system
  git-lfs # Git Large File Storage extension
  graphite-cli # Stacked diffs workflow for Git

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

  # TODO: Marked as broken as of 2025-07-05
  # https://github.com/NixOS/nixpkgs/pull/421135
  # nushellPlugins.net # Network utilities plugin
  # nushellPlugins.units # Unit conversion plugin

  # Node.js
  nodejs_24 # Node.js JavaScript runtime
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

  # Miscellaneous
  difftastic # Syntax-aware diffing tool
  direnv # Environment variable management per directory
  fastfetch # Fast system information tool
  jq # JSON processor and query tool
  just # Command runner and build tool
  mkcert # Local HTTPS certificate generator
  yq # YAML processor (jq for YAML)

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
  duckdb # Analytical in-process SQL database management system
  postgresql # Object-relational database system

  # Messaging
  natscli # Command-line client for NATS messaging system

  ##############################################################################
  # System Administration
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

  # Networking
  iproute2mac # IP routing utilities

  # Observability
  btop # Resource monitor with modern interface
  htop # Interactive process viewer
  hyperfine # Benchmarking tool
  procs # Modern process monitor

  ##############################################################################
  # Machine Learning
  ##############################################################################

  ollama # LLM runtime
]
