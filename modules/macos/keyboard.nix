_: {
  system = {
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

    defaults = {
      NSGlobalDomain = {
        # Enable key repeat for all apps
        ApplePressAndHoldEnabled = false;

        # Set key repeat to fastest rate
        InitialKeyRepeat = 15;
        KeyRepeat = 2;

        # Use Fn keys as standard function keys
        "com.apple.keyboard.fnState" = true;

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
      };

      CustomUserPreferences = {
        "com.apple.hitoolbox" = {
          # Do nothing with the Fn key
          AppleFnUsageType = 0;

          # Disable dictation
          AppleDictationAutoEnable = 0;
        };
      };
    };
  };
}
