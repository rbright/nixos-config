{ config, pkgs, ... }:

{
  # Don't autoplay video
  system.defaults.CustomUserPreferences."com.apple.AppStore".UserSetAutoPlayVideoSetting = 0;
}
