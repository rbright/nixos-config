{ config, pkgs, ... }:

{
  # Disable drop shadow border around screenshots
  system.defaults.screencapture.disable-shadow = true;

  # Include date and time in screenshot filenames
  system.defaults.screencapture.include-date = true;

  # Set location of screenshots
  system.defaults.screencapture.location = "~/My Drive/Screenshots";

  # Show thumbnail after screenshot before saving
  system.defaults.screencapture.show-thumbnail = true;

  # Save screenshots as PNG files
  system.defaults.screencapture.target = "file";
  system.defaults.screencapture.type = "png";
}
