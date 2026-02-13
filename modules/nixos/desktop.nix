_: {
  services = {
    # Enable GNOME as the desktop environment for graphical sessions.
    desktopManager.gnome.enable = true;

    # Use GDM as the login/display manager.
    displayManager.gdm.enable = true;

    # Enable X11 and set the keyboard layout for GUI sessions.
    xserver.enable = true;
    xserver.xkb = {
      layout = "us";
      variant = "";
    };
  };
}
