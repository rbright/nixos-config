_: {
  system = {
    defaults = {
      NSGlobalDomain = {
        # Set tracking speed
        "com.apple.trackpad.scaling" = 0.6875;

        # Disable force click
        "com.apple.trackpad.forceClick" = false;

        # Enable secondary click
        "com.apple.trackpad.enableSecondaryClick" = true;

        # Disable natural scrolling
        "com.apple.swipescrolldirection" = false;
      };

      trackpad = {
        # Set tap sensitivity to Medium
        FirstClickThreshold = 1;
        SecondClickThreshold = 1;

        # Use three-finger tap for Look up & data detectors
        TrackpadThreeFingerTapGesture = 2;

        # Enable tap to click
        Clicking = true;

        # Enable right-click
        TrackpadRightClick = true;

        # Enable silent clicking
        ActuationStrength = 0;

        # Disable tap-to-drag
        Dragging = false;

        # Disable three-finger drag
        TrackpadThreeFingerDrag = false;
      };
    };
  };
}
