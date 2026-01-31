{
  config,
  user,
  ...
}: {
  imports = [
    ./entries
  ];

  local.dock = {
    # Enable the Dock
    enable = true;

    # Setup persistent Dock entries
    entries = [
      {path = "/Applications/Brave Browser.app/";}
      {path = "/Applications/Calendar.app/";}
      {path = "/Applications/Sunsama.app/";}
      {path = "/Applications/Linear.app/";}
      {path = "/Applications/Obsidian.app/";}
      {path = "/Applications/Ghostty.app/";}
      {path = "/Applications/Zed.app/";}
      {path = "/Applications/Visual Studio Code.app/";}
      {path = "/Applications/CodexMonitor.app/";}
      {path = "/Applications/Tower.app/";}
      {path = "/Applications/TablePlus.app/";}
      {
        path = "${config.users.users.${user}.home}/Downloads";
        section = "others";
        options = "--sort name --view grid --display stack";
      }
    ];
  };

  system = {
    defaults = {
      dock = {
        # Hide dock when inactive
        autohide = true;

        # Remove delay when hiding dock
        "autohide-delay" = 0.0;

        # Reduce delay when showing dock
        "autohide-time-modifier" = 0.2;

        # Don't show Dashboard as a Space
        "dashboard-in-overlay" = true;

        # Set speed of Mission Control animations
        "expose-animation-duration" = 0.2;

        # Don't group windows by application in Mission Control's Exposé
        "expose-group-apps" = false;

        # Set the size of the magnified Dock icons
        largesize = 64;

        # Enable launch animation
        launchanim = true;

        # Don't magnify Dock icons
        magnification = false;

        # Set the animation effect for the dock
        mineffect = "scale";

        # Don't minimize windows into their application icons
        "minimize-to-application" = false;

        # Enable highlight hover aeffect for grid view of a stack
        "mouse-over-hilite-stack" = true;

        # Don't automatically rearrange spaces based on most recent use
        "mru-spaces" = false;

        # Show dock on bottom
        orientation = "bottom";

        # Scroll up on a Dock icon to show all opened windows for an app
        "scroll-to-open" = true;

        # Show process indicators
        "show-process-indicators" = false;

        # Hide recent applications
        "show-recents" = false;

        # Don't make icons of hidden applications translucent
        showhidden = false;

        # Disable slow-motion minimize effect
        "slow-motion-allowed" = false;

        # Show dynamic icons
        "static-only" = false;

        # Set tile size
        tilesize = 48;
      };
    };
  };
}
