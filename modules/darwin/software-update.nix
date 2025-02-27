{ config, pkgs, ... }:

{
  # Don't automatically install macOS updates
  system.defaults.SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;

  # Enable auto-update for apps
  system.defaults.CustomUserPreferences."com.apple.commerce".AutoUpdate = true;

  # Check for software updates daily, not just once per week
  system.defaults.CustomUserPreferences."com.apple.SoftwareUpdate".AutomaticCheckEnabled = true;
  system.defaults.CustomUserPreferences."com.apple.SoftwareUpdate".ScheduleFrequency = 1;

  # Download new updates when available
  system.defaults.CustomUserPreferences."com.apple.SoftwareUpdate".AutomaticDownload = 1;

  # Install System data files & security updates
  system.defaults.CustomUserPreferences."com.apple.SoftwareUpdate".CriticalUpdateInstall = 1;
}
