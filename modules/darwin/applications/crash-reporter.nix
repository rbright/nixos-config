{ config, pkgs, ... }:

{
  # Disable crash reporter
  system.defaults.CustomUserPreferences."com.apple.CrashReporter".DialogType = "none";
}
