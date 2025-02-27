{ config, pkgs, ... }:

{
  # Disable "Downloaded from Internet" warnings
  system.defaults.LaunchServices.LSQuarantine = false;
}
