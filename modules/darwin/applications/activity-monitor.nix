{ config, pkgs, ... }:

{
  # Sort descending by CPU usage
  system.defaults.ActivityMonitor.SortColumn = "CPUUsage";
  system.defaults.ActivityMonitor.SortDirection = 0;
}
