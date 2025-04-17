{
  config,
  pkgs,
  lib,
  ...
}:

let
  user = "rbright";
  additionalFiles = import ./files.nix { inherit user config pkgs; };
in
{
  imports = [
    ./dock
  ];

  ##############################################################################
  # Users
  ##############################################################################

  # Setup the user
  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
    isHidden = false;
    shell = pkgs.zsh;
  };

  ##############################################################################
  # Homebrew
  ##############################################################################

  homebrew.enable = true;

  homebrew.onActivation = {
    # Don't automate update Homebrew and its formulae
    autoUpdate = false;

    # Uninstall formulae that are no longer present in the generated Brewfile
    cleanup = "uninstall";

    # Don't upgrade outdated formulae and Mac App Store apps
    upgrade = false;
  };

  # Install Homebrew Casks
  homebrew.casks = pkgs.callPackage ./casks.nix { };

  # Install application from the Mac App Store
  #
  # These app IDs are from using the mas CLI app
  # https://github.com/mas-cli/mas
  homebrew.masApps = {
    "DaisyDisk" = 411643860;
    "Harvest" = 506189836;
    "Icon Set Creator" = 939343785;
    "Pixelmator Pro" = 1289583905;
    "Xcode" = 497799835;
  };

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
    { path = "/Applications/ChatGPT.app/"; }
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
