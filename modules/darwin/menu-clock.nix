{ config, pkgs, ... }:

{
  # Show 24-hour clock
  system.defaults.menuExtraClock.Show24Hour = true;

  # Don't show date, day of month, or day of week
  system.defaults.menuExtraClock.ShowDate = 2;
  system.defaults.menuExtraClock.ShowDayOfMonth = false;
  system.defaults.menuExtraClock.ShowDayOfWeek = false;

  # Don't flash date separators or show seconds
  system.defaults.menuExtraClock.FlashDateSeparators = false;
  system.defaults.menuExtraClock.ShowSeconds = false;
}
