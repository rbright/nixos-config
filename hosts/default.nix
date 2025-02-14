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

        # Enable launch animation
        launchanim = true;

        # Show dock on bottom
        orientation = "bottom";

        # Show process indicators
        show-process-indicators = false;

        # Hide recent applications
        show-recents = false;

        # Show dynamic icons
        static-only = false;

        # Set tile size
        tilesize = 48;
      };

      finder = {
        # Hide full path in Finder title bar
        _FXShowPosixPathInTitle = false;

        # Sort folders first
        _FXSortFoldersFirst = true;

        # When performing a search, search the current folder by default
        FXDefaultSearchScope = "SCcf";

        # Hide hidden files
        AppleShowAllFiles = false;

        # Show external hard drives on desktop
        ShowExternalHardDrivesOnDesktop = false;

        # Show hard drives on desktop
        ShowHardDrivesOnDesktop = false;

        # Show mounted servers on desktop
        ShowMountedServersOnDesktop = false;

        # Show removable media on desktop
        ShowRemovableMediaOnDesktop = false;
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

      CustomUserPreferences = {
        NSGlobalDomain = {
          # Add a context menu item for showing the Web Inspector in web views
          WebKitDeveloperExtras = true;
        };

        # Enable auto-update for apps
        "com.apple.commerce".AutoUpdate = true;

        "com.apple.desktopservices" = {
          # Avoid creating .DS_Store files on network or USB volumes
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };

        "com.apple.print.PrintingPrefs" = {
          # Automatically quit printer app once the print jobs complete
          "Quit When Finished" = true;
        };

        "com.apple.screencapture" = {
          # Set the location of the screenshot
          location = "~/My Drive/Screenshots";

          # Set the type of screenshot
          type = "png";
        };

        # Prevent Photos from opening automatically when devices are plugged in
        "com.apple.ImageCapture".disableHotPlug = true;

        "com.apple.SoftwareUpdate" = {
          # Enable automatic software updates
          AutomaticCheckEnabled = true;

          # Check for software updates daily, not just once per week
          ScheduleFrequency = 1;

          # Download newly available updates in background
          AutomaticDownload = 1;

          # Install System data files & security updates
          CriticalUpdateInstall = 1;
        };

        "com.apple.CrashReporter" = {
          # Disable crash reporter
          DialogType = "none";
        };
      };
    };

    activationScripts.postUserActivation.text = ''
      # Following line should allow us to avoid a logout/login cycle
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';

    activationScripts.postActivation.text = ''
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
