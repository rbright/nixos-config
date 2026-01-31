_: {
  system = {
    defaults = {
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
        # Don't use separate spaces for each display
        "spans-displays" = true;
      };
    };
  };
}
