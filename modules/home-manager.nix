{
  config,
  pkgs,
  lib,
  user,
  ...
}:

let
  additionalFiles = import ./files.nix { inherit user config pkgs; };
in
{
  imports = [
    ./dock
  ];

  ##############################################################################
  # Home Manager
  ##############################################################################

  home-manager = {
    useGlobalPkgs = true;
    users.${user} =
      {
        pkgs,
        config,
        lib,
        ...
      }:
      {
        home = {
          enableNixpkgsReleaseCheck = false;
          packages = pkgs.callPackage ./packages.nix { };
          file = lib.mkMerge [
            additionalFiles
          ];
          stateVersion = "24.11";
        };
        programs = { };
      };
  };

  ##############################################################################
  # Dock
  ##############################################################################

  # Enable the Dock
  local.dock.enable = true;

  # Setup persistent Dock entries
  local.dock.entries = [
    { path = "/Applications/Brave Browser.app/"; }
    { path = "/Applications/Fantastical.app/"; }
    { path = "/Applications/Todoist.app/"; }
    { path = "/Applications/Linear.app/"; }
    { path = "/Applications/Mimestream.app/"; }
    { path = "/Applications/Obsidian.app/"; }
    { path = "/Applications/Cursor.app/"; }
    { path = "/Applications/Ghostty.app/"; }
    { path = "/Applications/Tower.app/"; }
    { path = "/Applications/TablePlus.app/"; }
    {
      path = "${config.users.users.${user}.home}/My Drive";
      section = "others";
      options = "--sort name --view grid --display stack";
    }
    {
      path = "${config.users.users.${user}.home}/Downloads";
      section = "others";
      options = "--sort name --view grid --display stack";
    }
  ];
}
