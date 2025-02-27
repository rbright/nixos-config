{ config, pkgs, ... }:

{
  # Enable swiping left or right with two fingers to navigate
  system.defaults.NSGlobalDomain.AppleEnableSwipeNavigateWithScrolls = true;
  system.defaults.NSGlobalDomain.AppleEnableMouseSwipeNavigateWithScrolls = true;

  # Set font smoothing level
  system.defaults.NSGlobalDomain.AppleFontSmoothing = 2;

  # Enable full keyboard access
  system.defaults.NSGlobalDomain.AppleKeyboardUIMode = 3;

  # Use dark mode
  system.defaults.NSGlobalDomain.AppleInterfaceStyle = "Dark";
  system.defaults.NSGlobalDomain.AppleInterfaceStyleSwitchesAutomatically = false;

  # Show all filename extensions
  system.defaults.NSGlobalDomain.AppleShowAllExtensions = true;

  # Hide hidden files
  system.defaults.NSGlobalDomain.AppleShowAllFiles = false;

  # Don't automatically terminate apps when they are idle
  system.defaults.NSGlobalDomain.NSDisableAutomaticTermination = true;

  # Save new documents to iCloud
  system.defaults.NSGlobalDomain.NSDocumentSaveNewDocumentsToCloud = true;

  # Add a context menu item for showing the Web Inspector in web views
  system.defaults.CustomUserPreferences.NSGlobalDomain.WebKitDeveloperExtras = true;

  # Avoid creating .DS_Store files on network or USB volumes
  system.defaults.CustomUserPreferences."com.apple.desktopservices".DSDontWriteNetworkStores = true;
  system.defaults.CustomUserPreferences."com.apple.desktopservices".DSDontWriteUSBStores = true;

  # Automatically quit printer app once the print jobs complete
  system.defaults.CustomUserPreferences."com.apple.print.PrintingPrefs".QuitWhenFinished = true;
}
