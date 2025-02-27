{ config, pkgs, ... }:

{
  # Set tracking speed
  system.defaults.NSGlobalDomain."com.apple.trackpad.scaling" = 0.6875;

  # Set tap sensitivity to Medium
  system.defaults.trackpad.FirstClickThreshold = 1;
  system.defaults.trackpad.SecondClickThreshold = 1;

  # Disable force click
  system.defaults.NSGlobalDomain."com.apple.trackpad.forceClick" = false;

  # Use three-finger tap for Look up & data detectors
  system.defaults.trackpad.TrackpadThreeFingerTapGesture = 2;

  # Enable secondary click
  system.defaults.NSGlobalDomain."com.apple.trackpad.enableSecondaryClick" = true;

  # Enable tap to click
  system.defaults.trackpad.Clicking = true;

  # Enable right-click
  system.defaults.trackpad.TrackpadRightClick = true;

  # Disable natural scrolling
  system.defaults.NSGlobalDomain."com.apple.swipescrolldirection" = false;

  # Enable silent clicking
  system.defaults.trackpad.ActuationStrength = 0;

  # Disable tap-to-drag
  system.defaults.trackpad.Dragging = false;

  # Disable three-finger drag
  system.defaults.trackpad.TrackpadThreeFingerDrag = false;
}
