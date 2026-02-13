{ pkgs, ... }:
with pkgs;
[
  ##############################################################################
  # Development Tools
  ##############################################################################

  # Mobile Application
  cocoapods # Dependency manager for Swift and Objective-C
  fastlane # Mobile app automation and deployment

  ##############################################################################
  # Miscellaneous
  ##############################################################################

  aerospace # Tiling window manager for macOS
  dockutil # Command-line utility for managing the Dock
  espanso # Text expander and snippet manager
  ice-bar # Menu bar management tool
  iproute2mac # IP routing utilities
  k3d # Lightweight Kubernetes cluster manager
  macmon # Monitor macOS system resources
  mas # Mac App Store command-line interface
  pinentry_mac # PIN entry dialog for GPG on macOS
  skhd # Hotkey daemon for macOS
  terminal-notifier # Send macOS User Notifications from the command-line
]
