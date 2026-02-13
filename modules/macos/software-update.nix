_: {
  system = {
    defaults = {
      SoftwareUpdate = {
        # Don't automatically install macOS updates
        AutomaticallyInstallMacOSUpdates = false;
      };

      CustomUserPreferences = {
        # Enable auto-update for apps
        "com.apple.commerce".AutoUpdate = true;

        "com.apple.SoftwareUpdate" = {
          # Check for software updates daily, not just once per week
          AutomaticCheckEnabled = true;
          ScheduleFrequency = 1;

          # Download new updates when available
          AutomaticDownload = 1;

          # Install System data files & security updates
          CriticalUpdateInstall = 1;
        };
      };
    };
  };
}
