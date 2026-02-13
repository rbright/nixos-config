_: {
  system = {
    defaults = {
      NSGlobalDomain = {
        # Show scrollbars automatically based on mouse or trackpad
        AppleShowScrollBars = "WhenScrolling";

        # Switch to a workspace that has a window of the application open
        AppleSpacesSwitchOnActivate = true;

        # Use fullscreen tabs
        AppleWindowTabbingMode = "fullscreen";

        # Animate opening and closing windows
        NSAutomaticWindowAnimationsEnabled = true;

        # Jump to the spot that's clicked on the scroll bar
        AppleScrollerPagingBehavior = true;

        # Enable smooth scrolling
        NSScrollAnimationEnabled = true;

        # Enable moving window by holding anywhere on the window
        NSWindowShouldDragOnGesture = true;
      };
    };
  };
}
