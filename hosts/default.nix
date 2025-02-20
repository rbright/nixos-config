################################################################################
# macOS Host Configuration
#
# Configuration options at https://daiderd.com/nix-darwin/manual/index.html
################################################################################

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

  ##############################################################################
  # Shells
  ##############################################################################

  environment.shells = [
    "/Users/rbright/.nix-profile/bin/nu"
  ];

  ##############################################################################
  # Packages
  ##############################################################################

  environment.systemPackages =
    with pkgs;
    [

    ]
    ++ (import ../modules/packages.nix { inherit pkgs; });

  ##############################################################################
  # Fonts
  ##############################################################################

  fonts.packages = with pkgs; [
    fira-code
    fira-code-symbols
    inter
    lato
    montserrat
    nerd-fonts.fira-code
    quicksand
  ];

  ############################################################################
  # Networking
  ############################################################################

  networking = {
    # Set friendly name for the system
    computerName = "Ryan's MacBook Pro";

    # Set system hostname
    hostName = "lambda";

    # Set network services to configure
    knownNetworkServices = [
      "USB 10/100/1000 LAN"
      "Wi-Fi"
      "Thunderbolt Bridge"
    ];

    # Set DNS servers
    dns = [
      "1.1.1.1"
      "1.0.0.1"
    ];

    # Enable Wake-on-LAN
    wakeOnLan = {
      enable = true;
    };
  };

  ##############################################################################
  # System Settings
  ##############################################################################

  system = {
    stateVersion = 5;

    ############################################################################
    # Startup
    ############################################################################

    startup = {
      # Disable startup chime
      chime = false;
    };

    ############################################################################
    # Keyboard
    ############################################################################

    keyboard = {
      # Disable key mapping
      enableKeyMapping = false;

      # Don't remap Caps Lock
      remapCapsLockToControl = false;
      remapCapsLockToEscape = false;

      # Don't swap modifiers keys
      swapLeftCommandAndLeftAlt = false;
      swapLeftCtrlAndFn = false;
    };

    ############################################################################
    # Defaults
    ############################################################################

    defaults = {

      ##########################################################################
      # Global Settings
      ##########################################################################

      NSGlobalDomain = {

        ########################################################################
        # Keyboard
        ########################################################################

        # Enable key repeat for all apps
        ApplePressAndHoldEnabled = false;

        # Set key repeat to fastest rate
        InitialKeyRepeat = 15;
        KeyRepeat = 2;

        # Disable automatic capitalization
        NSAutomaticCapitalizationEnabled = false;

        # Disable automatic dash substitution
        NSAutomaticDashSubstitutionEnabled = false;

        # Disable automatic inline prediction
        NSAutomaticInlinePredictionEnabled = false;

        # Disable automatic period substitution
        NSAutomaticPeriodSubstitutionEnabled = false;

        # Disable smart quote substitution
        NSAutomaticQuoteSubstitutionEnabled = false;

        # Disable automatic spelling correction
        NSAutomaticSpellingCorrectionEnabled = false;

        # Use Fn keys as standard function keys
        "com.apple.keyboard.fnState" = true;

        ########################################################################
        # Trackpad
        ########################################################################

        # Set tracking speed
        "com.apple.trackpad.scaling" = 0.6875;

        # Disable force click
        "com.apple.trackpad.forceClick" = false;

        # Enable secondary click
        "com.apple.trackpad.enableSecondaryClick" = true;

        # Disable natural scrolling
        "com.apple.swipescrolldirection" = false;

        ########################################################################
        # Sound
        ########################################################################

        # Disable sound feedback when volume is changed
        "com.apple.sound.beep.feedback" = 0;

        # Set alert volume to 50%
        "com.apple.sound.beep.volume" = 0.6065307;

        ########################################################################
        # Windows
        ########################################################################

        # Show scrollbars automatically based on mouse or trackpad
        AppleShowScrollBars = "WhenScrolling";

        # Switch to a workspace that has a window of the application open
        AppleSpacesSwitchOnActivate = true;

        # Use fullscreen tabs
        AppleWindowTabbingMode = "fullscreen";

        # Animate opening and closing windows
        NSAutomaticWindowAnimationsEnabled = true;

        # Jump to the spot that's clicked on the scroll bar
        AppleScrollerPagingBehavior = true;

        # Enable smooth scrolling
        NSScrollAnimationEnabled = true;

        # Enable moving window by holding anywhere on the window
        NSWindowShouldDragOnGesture = true;

        ########################################################################
        # General > Language & Region
        ########################################################################

        # Set temperature unit to Fahrenheit
        AppleTemperatureUnit = "Fahrenheit";

        # Force 24-hour time
        AppleICUForce24HourTime = true;

        ########################################################################
        # Miscellaneous
        ########################################################################

        # Enable swiping left or right with two fingers to navigate
        AppleEnableSwipeNavigateWithScrolls = true;
        AppleEnableMouseSwipeNavigateWithScrolls = true;

        # Set font smoothing level
        AppleFontSmoothing = 2;

        # Enable full keyboard access
        AppleKeyboardUIMode = 3;

        # Use dark mode
        AppleInterfaceStyle = "Dark";
        AppleInterfaceStyleSwitchesAutomatically = false;

        # Show all filename extensions
        AppleShowAllExtensions = true;

        # Hide hidden files
        AppleShowAllFiles = false;

        # Don't automatically terminate apps when they are idle
        NSDisableAutomaticTermination = true;

        # Save new documents to iCloud
        NSDocumentSaveNewDocumentsToCloud = true;
      };

      ##########################################################################
      # Network
      ##########################################################################

      alf = {
        # Don't automatically allow signed apps to accept incoming requests
        allowsignedenabled = 0;

        # Don't automatically allow signed downloads to accept incoming requests
        allowdownloadsignedenabled = 0;

        # Enable internal firewall
        globalstate = 1;

        # Enable logging of requests made to the firewall
        loggingenabled = 1;

        # Drop incoming ICMP requests
        stealthenabled = 1;
      };

      ##########################################################################
      # Control Center
      ##########################################################################

      controlcenter = {
        # Disable controls in menu bar
        AirDrop = false;
        Bluetooth = false;
        Display = false;
        FocusModes = false;
        NowPlaying = false;
        Sound = false;

        # Don't show Battery Percentage in menu bar
        BatteryShowPercentage = false;
      };

      ##########################################################################
      # Desktop
      ##########################################################################

      WindowManager = {
        # Hide icons on desktop
        StandardHideDesktopIcons = true;

        # Hide items in Stage Manager
        HideDesktop = true;

        # Click wallpaper to reveal desktop in Stage Manager
        EnableStandardClickToShowDesktop = false;

        # Disable Stage Manager
        GloballyEnabled = false;

        # Show windows from an application all at once in Stage Manager
        AppWindowGroupingBehavior = true;

        # Show widgets on desktop
        StandardHideWidgets = false;

        # Hide widgets in Stage Manager
        StageManagerHideWidgets = true;

        # Disable dragging windows to screen edges to tile
        EnableTilingByEdgeDrag = false;

        # Disable dragging windows to menu bar to fill screen
        EnableTopTilingByEdgeDrag = false;

        # Disable holding alt to tile windows
        EnableTilingOptionAccelerator = false;

        # Disable margin for tiled windows
        EnableTiledWindowMargins = false;
      };

      spaces = {
        # Use separate Spaces for each display
        spans-displays = false;
      };

      ##########################################################################
      # Dock
      ##########################################################################

      dock = {
        # Hide dock when inactive
        autohide = true;

        # Remove delay when hiding dock
        autohide-delay = 0.0;

        # Reduce delay when showing dock
        autohide-time-modifier = 0.2;

        # Don't show Dashboard as a Space
        dashboard-in-overlay = true;

        # Set speed of Mission Control animations
        expose-animation-duration = 0.2;

        # Don't group windows by application in Mission Control's Exposé
        expose-group-apps = false;

        # Set the size of the magnified Dock icons
        largesize = 64;

        # Enable launch animation
        launchanim = true;

        # Don't magnify Dock icons
        magnification = false;

        # Set the animation effect for the dock
        mineffect = "scale";

        # Don't minimize windows into their application icons
        minimize-to-application = false;

        # Enable highlight hover aeffect for grid view of a stack
        mouse-over-hilite-stack = true;

        # Don't automatically rearrange spaces based on most recent use
        mru-spaces = false;

        # Show dock on bottom
        orientation = "bottom";

        # Scroll up on a Dock icon to show all opened windows for an app
        scroll-to-open = true;

        # Show process indicators
        show-process-indicators = false;

        # Hide recent applications
        show-recents = false;

        # Don't make icons of hidden applications translucent
        showhidden = false;

        # Disable slow-motion minimize effect
        slow-motion-allowed = false;

        # Show dynamic icons
        static-only = false;

        # Set tile size
        tilesize = 48;
      };

      ##########################################################################
      # Finder
      ##########################################################################

      finder = {
        # Show all filename extensions
        AppleShowAllExtensions = true;

        # Hide hidden files
        AppleShowAllFiles = false;

        # Search current folder when performing a search
        FXDefaultSearchScope = "SCcf";

        # Disable warning when changing file extensions
        FXEnableExtensionChangeWarning = false;

        # Use Column View as the default Finder view
        FXPreferredViewStyle = "clmv";

        # Remove old trash items after 30 days
        FXRemoveOldTrashItems = true;

        # Open new windows in the Downloads folder
        NewWindowTarget = "Other";
        NewWindowTargetPath = "file:///Users/rbright/Downloads";

        # Don't show the Quit Finder menu item
        QuitMenuItem = false;

        # Show external hard drives on desktop
        ShowExternalHardDrivesOnDesktop = false;

        # Show hard drives on desktop
        ShowHardDrivesOnDesktop = false;

        # Show mounted servers on desktop
        ShowMountedServersOnDesktop = false;

        # Show removable media on desktop
        ShowRemovableMediaOnDesktop = false;

        # Show path breadcrumbs in Finder windows
        ShowPathbar = true;

        # Show the status bar in Finder windows
        ShowStatusBar = true;

        # Hide full path in Finder title bar
        _FXShowPosixPathInTitle = false;

        # Sort folders first
        _FXSortFoldersFirst = true;

        # Don't sort folders first on desktop
        _FXSortFoldersFirstOnDesktop = false;
      };

      ##########################################################################
      # Trackpad
      ##########################################################################

      trackpad = {
        # Enable silent clicking
        ActuationStrength = 0;

        # Enable tap to click
        Clicking = true;

        # Disable tap-to-drag
        Dragging = false;

        # Set tap sensitivity to Medium
        FirstClickThreshold = 1;
        SecondClickThreshold = 1;

        # Enable right-click on trackpad
        TrackpadRightClick = true;

        # Disable three-finger drag
        TrackpadThreeFingerDrag = false;

        # Use three-finger tap for Look up & data detectors
        TrackpadThreeFingerTapGesture = 2;
      };

      ##########################################################################
      # Menu Clock
      ##########################################################################

      menuExtraClock = {
        # Show 24-hour clock
        Show24Hour = true;

        # Don't show date, day of month, or day of week
        ShowDate = 2;
        ShowDayOfMonth = false;
        ShowDayOfWeek = false;

        # Don't flash date separators or show seconds
        FlashDateSeparators = false;
        ShowSeconds = false;
      };

      ##########################################################################
      # Launch Services
      ##########################################################################

      LaunchServices = {
        # Disable "Downloaded from Internet" warnings
        LSQuarantine = false;
      };

      ##########################################################################
      # Login Window
      ##########################################################################

      loginwindow = {
        # Disable guest account
        GuestEnabled = false;

        # Show list of users on the login screen
        SHOWFULLNAME = true;

        # Allow Restart, Shutdown, and Sleep while logged out
        RestartDisabled = false;
        ShutDownDisabled = false;
        SleepDisabled = false;

        # Allow Restart and Shutdown while logged in
        RestartDisabledWhileLoggedIn = false;
        ShutDownDisabledWhileLoggedIn = false;
      };

      ##########################################################################
      # Activity Monitor
      ##########################################################################

      ActivityMonitor = {
        # Sort descending by CPU usage
        SortColumn = "CPUUsage";
        SortDirection = 0;
      };

      ##########################################################################
      # Screen Capture
      ##########################################################################

      screencapture = {
        # Disable drop shadow border around screenshots
        disable-shadow = true;

        # Include date and time in screenshot filenames
        include-date = true;

        # Set location of screenshots
        location = "~/My Drive/Screenshots";

        # Show thumbnail after screenshot before saving
        show-thumbnail = true;

        # Save screenshots as PNG files
        target = "file";
        type = "png";
      };

      ##########################################################################
      # Screen Saver
      ##########################################################################

      screensaver = {
        askForPassword = true;
      };

      ##########################################################################
      # Software Update
      ##########################################################################

      SoftwareUpdate = {
        # Don't automatically install macOS updates
        AutomaticallyInstallMacOSUpdates = false;
      };

      ##########################################################################
      # Custom System Preferences
      ##########################################################################

      CustomSystemPreferences = { };

      ##########################################################################
      # Custom User Preferences
      ##########################################################################

      CustomUserPreferences = {

        ########################################################################
        # General > Language & Region
        ########################################################################

        # Set supported languages
        NSGlobalDomain.AppleLanguages = [ "en-US" ];

        # Set supported languages
        NSGlobalDomain.AppleLocale = "en-US";

        # Set the first day of the week to Monday
        NSGlobalDomain.AppleFirstWeekday = {
          gregorian = 2;
        };

        # Set the date format to "MM/dd/yyyy"
        NSGlobalDomain.AppleICUDateFormatStrings = {
          "1" = "y-MM-dd";
        };

        ########################################################################
        # Keyboard
        ########################################################################

        # Do nothing with the Fn key
        "com.apple.hitoolbox".AppleFnUsageType = 0;

        # Disable dictation
        "com.apple.hitoolbox".AppleDictationAutoEnable = 0;

        ########################################################################
        # Mouse
        ########################################################################

        # Set mouse tracking speed
        NSGlobalDomain."com.apple.mouse.scaling" = 0.5;

        # Disable mouse acceleration
        NSGlobalDomain."com.apple.mouse.linear" = 1;

        # Set double-click speed
        NSGlobalDomain."com.apple.mouse.doubleClickThreshold" = 0.5;

        # Set scrolling speed
        NSGlobalDomain."com.apple.scrollwheel.scaling" = 0.75;

        ########################################################################
        # Finder
        ########################################################################

        # Empty trash securely
        "com.apple.finder".EmptyTrashSecurely = true;

        # Don't warn when emptying trash
        "com.apple.finder".WarnOnEmptyTrash = false;

        ########################################################################
        # Login Window
        ########################################################################

        # Don't reopen windows when logging back in
        "com.apple.loginwindow".LoginwindowLaunchesRelaunchApps = 0;
        "com.apple.loginwindow".TALLogoutSavesState = 0;

        ########################################################################
        # Software Update
        ########################################################################

        # Enable auto-update for apps
        "com.apple.commerce".AutoUpdate = true;

        # Check for software updates daily, not just once per week
        "com.apple.SoftwareUpdate".AutomaticCheckEnabled = true;
        "com.apple.SoftwareUpdate".ScheduleFrequency = 1;

        # Download new updates when available
        "com.apple.SoftwareUpdate".AutomaticDownload = 1;

        # Install System data files & security updates
        "com.apple.SoftwareUpdate".CriticalUpdateInstall = 1;

        ########################################################################
        # App Store
        ########################################################################

        # Don't autoplay video
        "com.apple.AppStore".UserSetAutoPlayVideoSetting = 0;

        ########################################################################
        # Apple Music
        ########################################################################

        # Download Dolby Atmos
        "com.apple.Music".downloadDolbyAtmos = 1;

        # Enable Lossless Audio with ALAC up to 24-bit / 48 kHz
        "com.apple.Music".losslessEnabled = 1;
        "com.apple.Music".preferredDownloadAudioQuality = 15;
        "com.apple.Music".preferredStreamPlaybackAudioQuality = 15;

        # Disable playback notifications
        "com.apple.Music".userWantsPlaybackNotifications = 0;

        ########################################################################
        # Crash Reporter
        ########################################################################

        # Disable crash reporter
        "com.apple.CrashReporter".DialogType = "none";

        ########################################################################
        # Image Capture
        ########################################################################

        # Prevent Photos from opening automatically when devices are plugged in
        "com.apple.ImageCapture".disableHotPlug = true;

        ########################################################################
        # Spotlight
        ########################################################################

        "com.apple.Spotlight".orderedItems = [
          {
            enabled = 0;
            name = "APPLICATIONS";
          }
          {
            enabled = 0;
            name = "BOOKMARKS";
          }
          {
            enabled = 0;
            name = "MENU_EXPRESSION";
          }
          {
            enabled = 0;
            name = "CONTACT";
          }
          {
            enabled = 0;
            name = "MENU_CONVERSION";
          }
          {
            enabled = 0;
            name = "MENU_DEFINITION";
          }
          {
            enabled = 0;
            name = "SOURCE";
          }
          {
            enabled = 0;
            name = "DOCUMENTS";
          }
          {
            enabled = 0;
            name = "EVENT_TODO";
          }
          {
            enabled = 0;
            name = "DIRECTORIES";
          }
          {
            enabled = 0;
            name = "FONTS";
          }
          {
            enabled = 0;
            name = "IMAGES";
          }
          {
            enabled = 0;
            name = "MESSAGES";
          }
          {
            enabled = 0;
            name = "MOVIES";
          }
          {
            enabled = 0;
            name = "MUSIC";
          }
          {
            enabled = 0;
            name = "MENU_OTHER";
          }
          {
            enabled = 0;
            name = "PDF";
          }
          {
            enabled = 0;
            name = "PRESENTATIONS";
          }
          {
            enabled = 0;
            name = "MENU_SPOTLIGHT_SUGGESTIONS";
          }
          {
            enabled = 0;
            name = "SPREADSHEETS";
          }
          {
            enabled = 0;
            name = "SYSTEM_PREFS";
          }
          {
            enabled = 0;
            name = "TIPS";
          }
        ];

        ########################################################################
        # TextEdit
        ########################################################################

        # Don't check spelling while typing
        "com.apple.TextEdit".CheckSpellingWhileTyping = 0;

        # Don't correct spelling automatically
        "com.apple.TextEdit".CorrectSpellingAutomatically = 0;

        # Disable rich text
        "com.apple.TextEdit".RichText = 0;

        # Disable smart copy paste
        "com.apple.TextEdit".SmartCopyPaste = 0;

        # Disable smart dashes
        "com.apple.TextEdit".SmartDashes = 0;

        # Disable smart quotes
        "com.apple.TextEdit".SmartQuotes = 0;

        # Disable smart substitutions in rich text only
        "com.apple.TextEdit".SmartSubstitutionsEnabledInRichTextOnly = 0;

        # Disable text replacement
        "com.apple.TextEdit".TextReplacement = 0;

        ########################################################################
        # Miscellaneous
        ########################################################################

        # Add a context menu item for showing the Web Inspector in web views
        NSGlobalDomain.WebKitDeveloperExtras = true;

        # Avoid creating .DS_Store files on network or USB volumes
        "com.apple.desktopservices".DSDontWriteNetworkStores = true;
        "com.apple.desktopservices".DSDontWriteUSBStores = true;

        # Automatically quit printer app once the print jobs complete
        "com.apple.print.PrintingPrefs".QuitWhenFinished = true;
      };
    };

    ############################################################################
    # Activation Scripts
    ############################################################################

    activationScripts.postUserActivation.text = ''
      # Avoid logout/login cycle to apply settings
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';
  };
}
