{ config, pkgs, ... }:

{

  # Prevent Photos from opening automatically when devices are plugged in
  system.defaults.CustomUserPreferences."com.apple.ImageCapture".disableHotPlug = true;
}
