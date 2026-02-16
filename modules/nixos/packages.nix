{ pkgs, ... }:
with pkgs;
[
  # Browsers
  brave # Privacy-oriented browser for Desktop and Laptop computers
  google-chrome # Google's web browser

  # Terminal
  ghostty # Fast, feature-rich terminal emulator
  wezterm # GPU-accelerated cross-platform terminal emulator and multiplexer

  # Development Tools
  android-studio # Official IDE for Android development
  atlas # Manage your database schema as code
  bun # Fast JavaScript runtime, package manager, and bundler
  codex # Codex CLI (sourced via codexCliNix overlay in hosts/omega/flake.nix)
  figma-linux # Desktop client for Figma on Linux
  gcc # GNU C compiler toolchain (needed for building native Neovim plugins)
  postman # API development and testing platform
  proxyman # Web debugging proxy
  uv # Extremely fast Python package installer and resolver, written in Rust
  vscode # Code editor developed by Microsoft
  zed-editor # High-performance, multiplayer code editor from the creators of Atom and Tree-sitter
  zulu17 # OpenJDK distribution (Java 17)

  # Productivity Tools
  calibre # E-book management and conversion tool
  cider-2 # Apple Music client for Linux
  obsidian # Powerful knowledge base that works on top of a local folder of plain text Markdown files
  sunsama # Digital daily planner that helps you feel calm and stay focused

  # Communication Tools
  discord # Chat and messaging platform
  slack # Team communication and collaboration platform
  thunderbird # Open-source email, calendar, and chat client
  zoom-us # Video conferencing and webinar platform

  # Finance Tools
  ledger-live-desktop # Cryptocurrency wallet and portfolio manager

  # Utilities
  _1password-cli # Command-line client for 1Password
  _1password-gui # Desktop GUI for 1Password
  localsend # Cross-platform file sharing over local network
  proton-pass # Password manager by Proton
  realvnc-vnc-viewer # Remote desktop viewing application
]
