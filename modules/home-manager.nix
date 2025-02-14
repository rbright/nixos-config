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

  # It me
  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
    isHidden = false;
    shell = pkgs.zsh;
  };

  homebrew = {
    enable = true;
    casks = pkgs.callPackage ./casks.nix { };
    onActivation = {
      autoUpdate = true;
      cleanup = "uninstall";
      upgrade = true;
    };

    # These app IDs are from using the mas CLI app
    # https://github.com/mas-cli/mas
    masApps = {
      "DaisyDisk" = 411643860;
      "Harvest" = 506189836;
      "Icon Set Creator" = 939343785;
      "Notability" = 360593530;
      "Pixelmator Pro" = 1289583905;
      "Xcode" = 497799835;
    };
  };

  # Enable home-manager
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

  # Fully declarative dock using the latest from Nix Store
  local.dock.enable = true;
  local.dock.entries = [
    { path = "/Applications/ChatGPT.app/"; }
    { path = "/Applications/Brave Browser.app/"; }
    { path = "/Applications/Fantastical.app/"; }
    { path = "/Applications/Todoist.app/"; }
    { path = "/Applications/Linear.app/"; }
    { path = "/Applications/Obsidian.app/"; }
    { path = "/Applications/Cursor.app/"; }
    { path = "/Applications/Warp.app/"; }
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
