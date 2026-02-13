_: {
  system = {
    defaults = {
      screencapture = {
        # Disable drop shadow border around screenshots
        "disable-shadow" = true;

        # Include date and time in screenshot filenames
        "include-date" = true;

        # Set location of screenshots
        location = "~/My Drive/Screenshots";

        # Show thumbnail after screenshot before saving
        "show-thumbnail" = true;

        # Save screenshots as PNG files
        target = "file";
        type = "png";
      };
    };
  };
}
