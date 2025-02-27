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

  ##############################################################################
  # Nix
  ##############################################################################

  nix.enable = false;
  nix.package = pkgs.nix;

  nix.settings = {
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

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  system.checks.verifyNixPath = false;
  system.stateVersion = 5;

  ##############################################################################
  # Startup
  ##############################################################################

  system.startup.chime = false;

  ##############################################################################
  # Launch Services
  ##############################################################################

  system.defaults.LaunchServices.LSQuarantine = false;

  ##############################################################################
  # Launch Services
  ##############################################################################

  ##############################################################################
  # Activation Scripts
  ##############################################################################

  system.activationScripts.postUserActivation.text = ''
    # Avoid logout/login cycle to apply settings
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';

  ##############################################################################
  # Shells
  ##############################################################################

  environment.shells = [
    "/Users/rbright/.nix-profile/bin/nu"
  ];

  ##############################################################################
  # System Packages
  ##############################################################################

  environment.systemPackages =
    with pkgs;
    [

    ]
    ++ (import ../modules/packages.nix { inherit pkgs; });

  ##########################################################################
  # Login Window
  ##########################################################################

  # Disable guest account
  system.defaults.loginwindow.GuestEnabled = false;

  # Show list of users on the login screen
  system.defaults.loginwindow.SHOWFULLNAME = true;

  # Allow Restart, Shutdown, and Sleep while logged out
  system.defaults.loginwindow.RestartDisabled = false;
  system.defaults.loginwindow.ShutDownDisabled = false;
  system.defaults.loginwindow.SleepDisabled = false;

  # Allow Restart and Shutdown while logged in
  system.defaults.loginwindow.RestartDisabledWhileLoggedIn = false;
  system.defaults.loginwindow.ShutDownDisabledWhileLoggedIn = false;

  # Don't reopen windows when logging back in
  system.defaults.CustomUserPreferences."com.apple.loginwindow".LoginwindowLaunchesRelaunchApps = 0;
  system.defaults.CustomUserPreferences."com.apple.loginwindow".TALLogoutSavesState = 0;

  ##############################################################################
  # Networking
  ##############################################################################

  # Set friendly name for the system
  networking.computerName = "Ryan's MacBook Pro";

  # Set system hostname
  networking.hostName = "lambda";

  # Set network services to configure
  networking.knownNetworkServices = [
    "USB 10/100/1000 LAN"
    "Wi-Fi"
    "Thunderbolt Bridge"
  ];

  # Set DNS servers
  networking.dns = [
    "1.1.1.1"
    "1.0.0.1"
  ];

  # Enable Wake-on-LAN
  networking.wakeOnLan = {
    enable = true;
  };

  ##############################################################################
  # Networking > Firewall
  ##############################################################################

  # Don't automatically allow signed apps to accept incoming requests
  system.defaults.alf.allowsignedenabled = 0;

  # Don't automatically allow signed downloads to accept incoming requests
  system.defaults.alf.allowdownloadsignedenabled = 0;

  # Enable internal firewall
  system.defaults.alf.globalstate = 1;

  # Enable logging of requests made to the firewall
  system.defaults.alf.loggingenabled = 1;

  # Drop incoming ICMP requests
  system.defaults.alf.stealthenabled = 1;

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

  ##############################################################################
  # Software Update
  ##############################################################################

  # Don't automatically install macOS updates
  system.defaults.SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;

  # Enable auto-update for apps
  system.defaults.CustomUserPreferences."com.apple.commerce".AutoUpdate = true;

  # Check for software updates daily, not just once per week
  system.defaults.CustomUserPreferences."com.apple.SoftwareUpdate".AutomaticCheckEnabled = true;
  system.defaults.CustomUserPreferences."com.apple.SoftwareUpdate".ScheduleFrequency = 1;

  # Download new updates when available
  system.defaults.CustomUserPreferences."com.apple.SoftwareUpdate".AutomaticDownload = 1;

  # Install System data files & security updates
  system.defaults.CustomUserPreferences."com.apple.SoftwareUpdate".CriticalUpdateInstall = 1;

  ##############################################################################
  # General > Language & Region
  ##############################################################################

  # Set temperature unit to Fahrenheit
  system.defaults.NSGlobalDomain.AppleTemperatureUnit = "Fahrenheit";

  # Force 24-hour time
  system.defaults.NSGlobalDomain.AppleICUForce24HourTime = true;

  # Set supported languages
  system.defaults.CustomUserPreferences.NSGlobalDomain.AppleLanguages = [ "en-US" ];

  # Set supported languages
  system.defaults.CustomUserPreferences.NSGlobalDomain.AppleLocale = "en-US";

  # Set the first day of the week to Monday
  system.defaults.CustomUserPreferences.NSGlobalDomain.AppleFirstWeekday = {
    gregorian = 2;
  };

  # Set the date format to "MM/dd/yyyy"
  system.defaults.CustomUserPreferences.NSGlobalDomain.AppleICUDateFormatStrings = {
    "1" = "y-MM-dd";
  };

  ##############################################################################
  # Control Center
  ##############################################################################

  # Disable controls in menu bar
  system.defaults.controlcenter.AirDrop = false;
  system.defaults.controlcenter.BatteryShowPercentage = false;
  system.defaults.controlcenter.Bluetooth = false;
  system.defaults.controlcenter.Display = false;
  system.defaults.controlcenter.FocusModes = false;
  system.defaults.controlcenter.NowPlaying = false;
  system.defaults.controlcenter.Sound = false;

  ##############################################################################
  # Menu Clock
  ##############################################################################

  # Show 24-hour clock
  system.defaults.menuExtraClock.Show24Hour = true;

  # Don't show date, day of month, or day of week
  system.defaults.menuExtraClock.ShowDate = 2;
  system.defaults.menuExtraClock.ShowDayOfMonth = false;
  system.defaults.menuExtraClock.ShowDayOfWeek = false;

  # Don't flash date separators or show seconds
  system.defaults.menuExtraClock.FlashDateSeparators = false;
  system.defaults.menuExtraClock.ShowSeconds = false;

  ##############################################################################
  # Desktop
  ##############################################################################

  # Hide icons on desktop
  system.defaults.WindowManager.StandardHideDesktopIcons = true;

  # Hide items in Stage Manager
  system.defaults.WindowManager.HideDesktop = true;

  # Click wallpaper to reveal desktop in Stage Manager
  system.defaults.WindowManager.EnableStandardClickToShowDesktop = false;

  # Disable Stage Manager
  system.defaults.WindowManager.GloballyEnabled = false;

  # Show windows from an application all at once in Stage Manager
  system.defaults.WindowManager.AppWindowGroupingBehavior = true;

  # Show widgets on desktop
  system.defaults.WindowManager.StandardHideWidgets = false;

  # Hide widgets in Stage Manager
  system.defaults.WindowManager.StageManagerHideWidgets = true;

  # Disable dragging windows to screen edges to tile
  system.defaults.WindowManager.EnableTilingByEdgeDrag = false;

  # Disable dragging windows to menu bar to fill screen
  system.defaults.WindowManager.EnableTopTilingByEdgeDrag = false;

  # Disable holding alt to tile windows
  system.defaults.WindowManager.EnableTilingOptionAccelerator = false;

  # Disable margin for tiled windows
  system.defaults.WindowManager.EnableTiledWindowMargins = false;

  # Use separate Spaces for each display
  system.defaults.spaces.spans-displays = false;

  ##############################################################################
  # Dock
  ##############################################################################

  # Hide dock when inactive
  system.defaults.dock.autohide = true;

  # Remove delay when hiding dock
  system.defaults.dock.autohide-delay = 0.0;

  # Reduce delay when showing dock
  system.defaults.dock.autohide-time-modifier = 0.2;

  # Don't show Dashboard as a Space
  system.defaults.dock.dashboard-in-overlay = true;

  # Set speed of Mission Control animations
  system.defaults.dock.expose-animation-duration = 0.2;

  # Don't group windows by application in Mission Control's Exposé
  system.defaults.dock.expose-group-apps = false;

  # Set the size of the magnified Dock icons
  system.defaults.dock.largesize = 64;

  # Enable launch animation
  system.defaults.dock.launchanim = true;

  # Don't magnify Dock icons
  system.defaults.dock.magnification = false;

  # Set the animation effect for the dock
  system.defaults.dock.mineffect = "scale";

  # Don't minimize windows into their application icons
  system.defaults.dock.minimize-to-application = false;

  # Enable highlight hover aeffect for grid view of a stack
  system.defaults.dock.mouse-over-hilite-stack = true;

  # Don't automatically rearrange spaces based on most recent use
  system.defaults.dock.mru-spaces = false;

  # Show dock on bottom
  system.defaults.dock.orientation = "bottom";

  # Scroll up on a Dock icon to show all opened windows for an app
  system.defaults.dock.scroll-to-open = true;

  # Show process indicators
  system.defaults.dock.show-process-indicators = true;

  # Hide recent applications
  system.defaults.dock.show-recents = false;

  # Don't make icons of hidden applications translucent
  system.defaults.dock.showhidden = false;

  # Disable slow-motion minimize effect
  system.defaults.dock.slow-motion-allowed = false;

  # Show dynamic icons
  system.defaults.dock.static-only = false;

  # Set tile size
  system.defaults.dock.tilesize = 48;

  ##############################################################################
  # Screen Saver
  ##############################################################################

  system.defaults.screensaver.askForPassword = true;

  ##############################################################################
  # Sound
  ##############################################################################

  # Disable sound feedback when volume is changed
  system.defaults.NSGlobalDomain."com.apple.sound.beep.feedback" = 0;

  # Set alert volume to 50%
  system.defaults.NSGlobalDomain."com.apple.sound.beep.volume" = 0.6065307;

  ##############################################################################
  # Keyboard
  ##############################################################################

  # Disable key mapping
  system.keyboard.enableKeyMapping = false;

  # Don't remap Caps Lock
  system.keyboard.remapCapsLockToControl = false;
  system.keyboard.remapCapsLockToEscape = false;

  # Don't swap modifiers keys
  system.keyboard.swapLeftCommandAndLeftAlt = false;
  system.keyboard.swapLeftCtrlAndFn = false;

  # Enable key repeat for all apps
  system.defaults.NSGlobalDomain.ApplePressAndHoldEnabled = false;

  # Set key repeat to fastest rate
  system.defaults.NSGlobalDomain.InitialKeyRepeat = 15;
  system.defaults.NSGlobalDomain.KeyRepeat = 2;

  # Use Fn keys as standard function keys
  system.defaults.NSGlobalDomain."com.apple.keyboard.fnState" = true;

  # Do nothing with the Fn key
  system.defaults.CustomUserPreferences."com.apple.hitoolbox".AppleFnUsageType = 0;

  # Disable dictation
  system.defaults.CustomUserPreferences."com.apple.hitoolbox".AppleDictationAutoEnable = 0;

  # Disable automatic capitalization
  system.defaults.NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;

  # Disable automatic dash substitution
  system.defaults.NSGlobalDomain.NSAutomaticDashSubstitutionEnabled = false;

  # Disable automatic inline prediction
  system.defaults.NSGlobalDomain.NSAutomaticInlinePredictionEnabled = false;

  # Disable automatic period substitution
  system.defaults.NSGlobalDomain.NSAutomaticPeriodSubstitutionEnabled = false;

  # Disable smart quote substitution
  system.defaults.NSGlobalDomain.NSAutomaticQuoteSubstitutionEnabled = false;

  # Disable automatic spelling correction
  system.defaults.NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;

  ##############################################################################
  # Mouse
  ##############################################################################

  # Set mouse tracking speed
  system.defaults.CustomUserPreferences.NSGlobalDomain."com.apple.mouse.scaling" = 0.5;

  # Disable mouse acceleration
  system.defaults.CustomUserPreferences.NSGlobalDomain."com.apple.mouse.linear" = 1;

  # Set double-click speed
  system.defaults.CustomUserPreferences.NSGlobalDomain."com.apple.mouse.doubleClickThreshold" = 0.5;

  # Set scrolling speed
  system.defaults.CustomUserPreferences.NSGlobalDomain."com.apple.scrollwheel.scaling" = 0.75;

  ##############################################################################
  # Trackpad
  ##############################################################################

  # Set tracking speed
  system.defaults.NSGlobalDomain."com.apple.trackpad.scaling" = 0.6875;

  # Set tap sensitivity to Medium
  system.defaults.trackpad.FirstClickThreshold = 1;
  system.defaults.trackpad.SecondClickThreshold = 1;

  # Disable force click
  system.defaults.NSGlobalDomain."com.apple.trackpad.forceClick" = false;

  # Use three-finger tap for Look up & data detectors
  system.defaults.trackpad.TrackpadThreeFingerTapGesture = 2;

  # Enable secondary click
  system.defaults.NSGlobalDomain."com.apple.trackpad.enableSecondaryClick" = true;

  # Enable tap to click
  system.defaults.trackpad.Clicking = true;

  # Enable right-click
  system.defaults.trackpad.TrackpadRightClick = true;

  # Disable natural scrolling
  system.defaults.NSGlobalDomain."com.apple.swipescrolldirection" = false;

  # Enable silent clicking
  system.defaults.trackpad.ActuationStrength = 0;

  # Disable tap-to-drag
  system.defaults.trackpad.Dragging = false;

  # Disable three-finger drag
  system.defaults.trackpad.TrackpadThreeFingerDrag = false;

  ##############################################################################
  # Windows
  ##############################################################################

  # Show scrollbars automatically based on mouse or trackpad
  system.defaults.NSGlobalDomain.AppleShowScrollBars = "WhenScrolling";

  # Switch to a workspace that has a window of the application open
  system.defaults.NSGlobalDomain.AppleSpacesSwitchOnActivate = true;

  # Use fullscreen tabs
  system.defaults.NSGlobalDomain.AppleWindowTabbingMode = "fullscreen";

  # Animate opening and closing windows
  system.defaults.NSGlobalDomain.NSAutomaticWindowAnimationsEnabled = true;

  # Jump to the spot that's clicked on the scroll bar
  system.defaults.NSGlobalDomain.AppleScrollerPagingBehavior = true;

  # Enable smooth scrolling
  system.defaults.NSGlobalDomain.NSScrollAnimationEnabled = true;

  # Enable moving window by holding anywhere on the window
  system.defaults.NSGlobalDomain.NSWindowShouldDragOnGesture = true;

  ##############################################################################
  # Finder
  ##############################################################################

  # Show all filename extensions
  system.defaults.finder.AppleShowAllExtensions = true;

  # Hide hidden files
  system.defaults.finder.AppleShowAllFiles = false;

  # Search current folder when performing a search
  system.defaults.finder.FXDefaultSearchScope = "SCcf";

  # Disable warning when changing file extensions
  system.defaults.finder.FXEnableExtensionChangeWarning = false;

  # Use Column View as the default Finder view
  system.defaults.finder.FXPreferredViewStyle = "clmv";

  # Remove old trash items after 30 days
  system.defaults.finder.FXRemoveOldTrashItems = true;

  # Open new windows in the Downloads folder
  system.defaults.finder.NewWindowTarget = "Other";
  system.defaults.finder.NewWindowTargetPath = "file:///Users/rbright/Downloads";

  # Don't show the Quit Finder menu item
  system.defaults.finder.QuitMenuItem = false;

  # Show external hard drives on desktop
  system.defaults.finder.ShowExternalHardDrivesOnDesktop = false;

  # Show hard drives on desktop
  system.defaults.finder.ShowHardDrivesOnDesktop = false;

  # Show mounted servers on desktop
  system.defaults.finder.ShowMountedServersOnDesktop = false;

  # Show removable media on desktop
  system.defaults.finder.ShowRemovableMediaOnDesktop = false;

  # Show path breadcrumbs in Finder windows
  system.defaults.finder.ShowPathbar = true;

  # Show the status bar in Finder windows
  system.defaults.finder.ShowStatusBar = true;

  # Hide full path in Finder title bar
  system.defaults.finder._FXShowPosixPathInTitle = false;

  # Sort folders first
  system.defaults.finder._FXSortFoldersFirst = true;

  # Don't sort folders first on desktop
  system.defaults.finder._FXSortFoldersFirstOnDesktop = false;

  # Empty trash securely
  system.defaults.CustomUserPreferences."com.apple.finder".EmptyTrashSecurely = true;

  # Don't warn when emptying trash
  system.defaults.CustomUserPreferences."com.apple.finder".WarnOnEmptyTrash = false;

  ##############################################################################
  # Applications > Activity Monitor
  ##############################################################################

  # Sort descending by CPU usage
  system.defaults.ActivityMonitor.SortColumn = "CPUUsage";
  system.defaults.ActivityMonitor.SortDirection = 0;

  ##############################################################################
  # Applications > App Store
  ##############################################################################

  # Don't autoplay video
  system.defaults.CustomUserPreferences."com.apple.AppStore".UserSetAutoPlayVideoSetting = 0;

  ##############################################################################
  # Applications > Apple Music
  ##############################################################################

  # Download Dolby Atmos
  system.defaults.CustomUserPreferences."com.apple.Music".downloadDolbyAtmos = 1;

  # Enable Lossless Audio with ALAC up to 24-bit / 48 kHz
  system.defaults.CustomUserPreferences."com.apple.Music".losslessEnabled = 1;
  system.defaults.CustomUserPreferences."com.apple.Music".preferredDownloadAudioQuality = 15;
  system.defaults.CustomUserPreferences."com.apple.Music".preferredStreamPlaybackAudioQuality = 15;

  # Disable playback notifications
  system.defaults.CustomUserPreferences."com.apple.Music".userWantsPlaybackNotifications = 0;

  ##############################################################################
  # Miscellaneous
  ##############################################################################

  # Enable swiping left or right with two fingers to navigate
  system.defaults.NSGlobalDomain.AppleEnableSwipeNavigateWithScrolls = true;
  system.defaults.NSGlobalDomain.AppleEnableMouseSwipeNavigateWithScrolls = true;

  # Set font smoothing level
  system.defaults.NSGlobalDomain.AppleFontSmoothing = 2;

  # Enable full keyboard access
  system.defaults.NSGlobalDomain.AppleKeyboardUIMode = 3;

  # Use dark mode
  system.defaults.NSGlobalDomain.AppleInterfaceStyle = "Dark";
  system.defaults.NSGlobalDomain.AppleInterfaceStyleSwitchesAutomatically = false;

  # Show all filename extensions
  system.defaults.NSGlobalDomain.AppleShowAllExtensions = true;

  # Hide hidden files
  system.defaults.NSGlobalDomain.AppleShowAllFiles = false;

  # Don't automatically terminate apps when they are idle
  system.defaults.NSGlobalDomain.NSDisableAutomaticTermination = true;

  # Save new documents to iCloud
  system.defaults.NSGlobalDomain.NSDocumentSaveNewDocumentsToCloud = true;

  # Add a context menu item for showing the Web Inspector in web views
  system.defaults.CustomUserPreferences.NSGlobalDomain.WebKitDeveloperExtras = true;

  # Avoid creating .DS_Store files on network or USB volumes
  system.defaults.CustomUserPreferences."com.apple.desktopservices".DSDontWriteNetworkStores = true;
  system.defaults.CustomUserPreferences."com.apple.desktopservices".DSDontWriteUSBStores = true;

  # Automatically quit printer app once the print jobs complete
  system.defaults.CustomUserPreferences."com.apple.print.PrintingPrefs".QuitWhenFinished = true;

  ##############################################################################
  # Applications > Crash Reporter
  ##############################################################################

  # Disable crash reporter
  system.defaults.CustomUserPreferences."com.apple.CrashReporter".DialogType = "none";

  ##############################################################################
  # Applications > Image Capture
  ##############################################################################

  # Prevent Photos from opening automatically when devices are plugged in
  system.defaults.CustomUserPreferences."com.apple.ImageCapture".disableHotPlug = true;

  ##############################################################################
  # Applications > Screen Capture
  ##############################################################################

  # Disable drop shadow border around screenshots
  system.defaults.screencapture.disable-shadow = true;

  # Include date and time in screenshot filenames
  system.defaults.screencapture.include-date = true;

  # Set location of screenshots
  system.defaults.screencapture.location = "~/My Drive/Screenshots";

  # Show thumbnail after screenshot before saving
  system.defaults.screencapture.show-thumbnail = true;

  # Save screenshots as PNG files
  system.defaults.screencapture.target = "file";
  system.defaults.screencapture.type = "png";

  ##############################################################################
  # Applications > Spotlight
  ##############################################################################

  # Disable Spotlight
  system.defaults.CustomUserPreferences."com.apple.Spotlight".orderedItems = [
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

  ##############################################################################
  # Applications > TextEdit
  ##############################################################################

  # Don't check spelling while typing
  system.defaults.CustomUserPreferences."com.apple.TextEdit".CheckSpellingWhileTyping = 0;

  # Don't correct spelling automatically
  system.defaults.CustomUserPreferences."com.apple.TextEdit".CorrectSpellingAutomatically = 0;

  # Disable rich text
  system.defaults.CustomUserPreferences."com.apple.TextEdit".RichText = 0;

  # Disable smart copy paste
  system.defaults.CustomUserPreferences."com.apple.TextEdit".SmartCopyPaste = 0;

  # Disable smart dashes
  system.defaults.CustomUserPreferences."com.apple.TextEdit".SmartDashes = 0;

  # Disable smart quotes
  system.defaults.CustomUserPreferences."com.apple.TextEdit".SmartQuotes = 0;

  # Disable smart substitutions in rich text only
  system.defaults.CustomUserPreferences."com.apple.TextEdit".SmartSubstitutionsEnabledInRichTextOnly =
    0;

  # Disable text replacement
  system.defaults.CustomUserPreferences."com.apple.TextEdit".TextReplacement = 0;
}
