{
  config,
  pkgs,
  ...
}:
{
  homebrew = {
    # Enable Homebrew
    enable = true;

    onActivation = {
      # Don't automate update Homebrew and its formulae
      autoUpdate = false;

      # Uninstall formulae that are no longer present in the generated Brewfile
      cleanup = "uninstall";

      # Don't upgrade outdated formulae and Mac App Store apps
      upgrade = false;
    };

    # Ensure nix-darwin respects the declarative taps from nix-homebrew
    taps = builtins.attrNames config.nix-homebrew.taps;

    # Install Homebrew Brews
    brews = pkgs.callPackage ./brews.nix { };

    # Install Homebrew Casks
    casks = pkgs.callPackage ./casks.nix { };

    # Install application from the Mac App Store
    #
    # These app IDs are from using the mas CLI app
    # https://github.com/mas-cli/mas
    masApps = {
      "Amphetamine" = 937984704;
      "DaisyDisk" = 411643860;
      "Harvest" = 506189836;
      "Icon Set Creator" = 939343785;
      "Pixelmator Pro" = 1289583905;
      "Todoist" = 585829637;
      "Xcode" = 497799835;
    };
  };
}
