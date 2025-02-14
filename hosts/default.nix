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

    defaults = {
      NSGlobalDomain = {
        # Show all filename extensions
        AppleShowAllExtensions = true;

        # Enable key repeat for all apps
        ApplePressAndHoldEnabled = false;

        # Set key repeat to fastest rate
        KeyRepeat = 2; # Values: 120, 90, 60, 30, 12, 6, 2
        InitialKeyRepeat = 15; # Values: 120, 94, 68, 35, 25, 15

        # "com.apple.mouse.tapBehavior" = 1;
        # "com.apple.sound.beep.feedback" = 0;
        # "com.apple.sound.beep.volume" = 0.0;
      };

      dock = {
        # Hide dock when inactive
        autohide = true;

        # Remove delay when hiding dock
        autohide-delay = 0.0;

        # Reduce delay when showing dock
        autohide-time-modifier = 0.2;

        # Hide recent applications
        show-recents = false;

        # Enable launch animation
        launchanim = true;

        orientation = "bottom";
        tilesize = 48;
      };

      finder = {
        # Hide full path in Finder title bar
        _FXShowPosixPathInTitle = false;

        # Hide hidden files
        AppleShowAllFiles = false;
      };

      trackpad = {
        # Enable tap to click
        Clicking = true;

        # Enable three-finger drag
        TrackpadThreeFingerDrag = true;
      };

      LaunchServices = {
        # Disable "Downloaded from Internet" warnings
        LSQuarantine = false;
      };
    };

    activationScripts.postActivation.text = ''
      # Disable crash reporter
      defaults write com.apple.CrashReporter DialogType none

      # Enable firewall with logging and stealth mode
      echo "Configuring firewall..."
      /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
      /usr/libexec/ApplicationFirewall/socketfilterfw --setloggingmode on
      /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on

      # Prevent automatic whitelisting of built-in and signed software
      /usr/libexec/ApplicationFirewall/socketfilterfw --setallowsigned off
      /usr/libexec/ApplicationFirewall/socketfilterfw --setallowsignedapp off
    '';
  };
}
