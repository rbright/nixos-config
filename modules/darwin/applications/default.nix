# Import all modules
{ config, pkgs, ... }:

{
  imports = [
    ./activity-monitor.nix
    ./app-store.nix
    ./apple-music.nix
    ./crash-reporter.nix
    ./image-capture.nix
    ./screen-capture.nix
    ./spotlight.nix
    ./textedit.nix
  ];
}
