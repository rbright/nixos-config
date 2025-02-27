{ config, pkgs, ... }:

{
  # Set mouse tracking speed
  system.defaults.CustomUserPreferences.NSGlobalDomain."com.apple.mouse.scaling" = 0.5;

  # Disable mouse acceleration
  system.defaults.CustomUserPreferences.NSGlobalDomain."com.apple.mouse.linear" = 1;

  # Set double-click speed
  system.defaults.CustomUserPreferences.NSGlobalDomain."com.apple.mouse.doubleClickThreshold" = 0.5;

  # Set scrolling speed
  system.defaults.CustomUserPreferences.NSGlobalDomain."com.apple.scrollwheel.scaling" = 0.75;
}
