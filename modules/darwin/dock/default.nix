{
  config,
  user,
  ...
}:

{
  imports = [
    ./entries
  ];

  # Enable the Dock
  local.dock.enable = true;

  # Setup persistent Dock entries
  local.dock.entries = [
    { path = "/Applications/Brave Browser.app/"; }
    { path = "/Applications/Calendar.app/"; }
    { path = "/Applications/Sunsama.app/"; }
    { path = "/Applications/Linear.app/"; }
    { path = "/Applications/Obsidian.app/"; }
    { path = "/Applications/Ghostty.app/"; }
    { path = "/Applications/Zed.app/"; }
    { path = "/Applications/Visual Studio Code.app/"; }
    { path = "/Applications/CodexMonitor.app/"; }
    { path = "/Applications/Tower.app/"; }
    { path = "/Applications/TablePlus.app/"; }
    {
      path = "${config.users.users.${user}.home}/Downloads";
      section = "others";
      options = "--sort name --view grid --display stack";
    }
  ];

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
  system.defaults.dock.show-process-indicators = false;

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
}
