{
  pkgs,
  nixPiAgent ? null,
  ...
}:
with pkgs;
let
  # Use the FHS variant for broad extension compatibility and force libsecret
  # credential storage for stable Settings Sync/profile auth on Linux.
  vscodeWithKeyring =
    (vscode.override {
      commandLineArgs = "--password-store=gnome-libsecret";
    }).fhs;

  # Use external flake package source of truth; keep a local fallback for safety.
  piAgent =
    if nixPiAgent != null then
      nixPiAgent.packages.${pkgs.system}.pi-agent
    else
      pkgs.callPackage ../../pkgs/pi-coding-agent { };
in
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
  claude-code # Agentic coding tool that lives in your terminal, understands your codebase, and helps you code faster
  codex # Lightweight coding agent that runs in your terminal
  piAgent # Minimal terminal coding harness for agentic engineering workflows
  figma-linux # Desktop client for Figma on Linux
  gcc # GNU C compiler toolchain (needed for building native Neovim plugins)
  prek # Fast pre-commit hook runner and config manager
  postman # API development and testing platform
  proxyman # Web debugging proxy
  tableplus # Cross-platform database management tool
  uv # Extremely fast Python package installer and resolver, written in Rust
  vscodeWithKeyring # VS Code in FHS mode with libsecret-backed credential storage
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
  ffmpeg # Multimedia toolkit (includes ffplay)
  localsend # Cross-platform file sharing over local network
  proton-pass # Password manager by Proton
  realvnc-vnc-viewer # Remote desktop viewing application
]
