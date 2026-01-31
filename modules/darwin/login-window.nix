_: {
  system = {
    defaults = {
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

      CustomUserPreferences = {
        "com.apple.loginwindow" = {
          # Don't reopen windows when logging back in
          LoginwindowLaunchesRelaunchApps = 0;
          TALLogoutSavesState = 0;
        };
      };
    };
  };
}
