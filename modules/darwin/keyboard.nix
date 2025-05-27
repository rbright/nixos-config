_:

{
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
}
