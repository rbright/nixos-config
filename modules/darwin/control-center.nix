{ config, pkgs, ... }:

{
  # Disable controls in menu bar
  system.defaults.controlcenter.AirDrop = false;
  system.defaults.controlcenter.BatteryShowPercentage = false;
  system.defaults.controlcenter.Bluetooth = false;
  system.defaults.controlcenter.Display = false;
  system.defaults.controlcenter.FocusModes = false;
  system.defaults.controlcenter.NowPlaying = false;
  system.defaults.controlcenter.Sound = false;
}
