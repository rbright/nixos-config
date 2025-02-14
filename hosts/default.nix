{ config, pkgs, ... }:

let
  user = "rbright";
in

{
  imports = [
    ../modules/home-manager.nix
    ../modules
  ];

  nix = {
    enable = false;
    package = pkgs.nix;
    settings = {
      trusted-users = [
        "@admin"
        "${user}"
      ];
      substituters = [
        "https://nix-community.cachix.org"
        "https://cache.nixos.org"
      ];
      trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
    };

    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  system.checks.verifyNixPath = false;

  environment.systemPackages =
    with pkgs;
    [

    ]
    ++ (import ../modules/packages.nix { inherit pkgs; });

  system = {
    stateVersion = 5;

    # defaults = {
    #   NSGlobalDomain = {
    #     AppleShowAllExtensions = true;
    #     ApplePressAndHoldEnabled = false;

    #     KeyRepeat = 2; # Values: 120, 90, 60, 30, 12, 6, 2
    #     InitialKeyRepeat = 15; # Values: 120, 94, 68, 35, 25, 15

    #     "com.apple.mouse.tapBehavior" = 1;
    #     "com.apple.sound.beep.volume" = 0.0;
    #     "com.apple.sound.beep.feedback" = 0;
    #   };

    #   dock = {
    #     autohide = false;
    #     show-recents = false;
    #     launchanim = true;
    #     orientation = "bottom";
    #     tilesize = 48;
    #   };

    #   finder = {
    #     _FXShowPosixPathInTitle = false;
    #   };

    #   trackpad = {
    #     Clicking = true;
    #     TrackpadThreeFingerDrag = true;
    #   };
    # };
  };
}
