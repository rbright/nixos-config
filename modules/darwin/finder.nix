{
  config,
  user,
  ...
}: {
  system = {
    defaults = {
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
        NewWindowTargetPath = "file:///${config.users.users.${user}.home}/Downloads";

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

      CustomUserPreferences = {
        "com.apple.finder" = {
          # Empty trash securely
          EmptyTrashSecurely = true;

          # Don't warn when emptying trash
          WarnOnEmptyTrash = false;
        };
      };
    };
  };
}
