{
  pkgs,
  nixPiAgent,
  waybarAgentUsage,
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

  # External package sources of truth.
  piAgent = nixPiAgent.packages.${pkgs.stdenv.hostPlatform.system}.pi-agent;
  waybarAgentUsageBin = waybarAgentUsage.packages.${pkgs.stdenv.hostPlatform.system}.default;

  # Ensure btop can load NVIDIA NVML on NixOS hybrid/dGPU systems.
  btopWithNvml = lib.hiPrio (
    writeShellScriptBin "btop" ''
      export LD_LIBRARY_PATH="/run/opengl-driver/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
      exec ${btop}/bin/btop "$@"
    ''
  );

  # Enable chromium/electron syncobj explicit sync to reduce NVIDIA flicker.
  slackWithSyncobj = slack.overrideAttrs (old: {
    postFixup = (old.postFixup or "") + ''
      substituteInPlace $out/bin/slack \
        --replace-fail "WaylandWindowDecorations,WebRTCPipeWireCapturer" "WaylandWindowDecorations,WebRTCPipeWireCapturer,WaylandLinuxDrmSyncobj"
    '';
  });
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
  figma-linux # Desktop client for Figma on Linux
  gcc # GNU C compiler toolchain (needed for building native Neovim plugins)
  jetbrains.datagrip # Database IDE from JetBrains
  lazygit # Simple terminal UI for git commands
  piAgent # Minimal terminal coding harness for agentic engineering workflows
  waybarAgentUsageBin # Standalone Codex/Claude Waybar usage module backend
  prek # Fast pre-commit hook runner and config manager
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
  slackWithSyncobj # Team communication client with Wayland explicit-sync flag for NVIDIA
  zoom-us # Video conferencing and webinar platform

  # Finance Tools
  ledger-live-desktop # Cryptocurrency wallet and portfolio manager

  # Utilities
  _1password-cli # Command-line client for 1Password
  _1password-gui # Desktop GUI for 1Password
  btopWithNvml # Wrapped btop binary to expose NVIDIA NVML via /run/opengl-driver/lib
  ffmpeg # Multimedia toolkit (includes ffplay)
  gcsfuse # FUSE adapter for mounting Google Cloud Storage buckets as local filesystems
  mpv # Lightweight, scriptable media player
  localsend # Cross-platform file sharing over local network
  proton-pass # Password manager by Proton
  realvnc-vnc-viewer # Remote desktop viewing application
  wl-clipboard # Wayland clipboard CLI (`wl-copy`/`wl-paste`) shared by Hypr/Vicinae workflows
]
