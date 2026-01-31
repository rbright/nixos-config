_: {
  system = {
    defaults = {
      NSGlobalDomain = {
        # Enable swiping left or right with two fingers to navigate
        AppleEnableSwipeNavigateWithScrolls = true;
        AppleEnableMouseSwipeNavigateWithScrolls = true;

        # Set font smoothing level
        AppleFontSmoothing = 2;

        # Enable full keyboard access
        AppleKeyboardUIMode = 3;

        # Use dark mode
        AppleInterfaceStyle = "Dark";
        AppleInterfaceStyleSwitchesAutomatically = false;

        # Show all filename extensions
        AppleShowAllExtensions = true;

        # Hide hidden files
        AppleShowAllFiles = false;

        # Don't automatically terminate apps when they are idle
        NSDisableAutomaticTermination = true;

        # Save new documents to iCloud
        NSDocumentSaveNewDocumentsToCloud = true;
      };

      CustomUserPreferences = {
        NSGlobalDomain = {
          # Add a context menu item for showing the Web Inspector in web views
          WebKitDeveloperExtras = true;
        };

        # Avoid creating .DS_Store files on network or USB volumes
        "com.apple.desktopservices" = {
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };

        # Automatically quit printer app once the print jobs complete
        "com.apple.print.PrintingPrefs".QuitWhenFinished = true;
      };
    };
  };
}
