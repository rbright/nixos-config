_:

{
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
}
