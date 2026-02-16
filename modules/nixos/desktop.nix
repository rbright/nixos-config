{ pkgs, ... }:
{
  # Use Hyprland as the compositor/session manager.
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  # Needed by many GTK/GNOME settings and apps for persisted preferences.
  programs.dconf.enable = true;

  services = {
    # Keep GDM as the login manager. Run the greeter on Xorg for better
    # keyboard reliability on NVIDIA setups, while keeping Hyprland Wayland.
    displayManager.gdm = {
      enable = true;
      wayland = false;
    };

    # Power management daemon required by many desktop components.
    upower.enable = true;

    # Required for GDM's Xorg greeter path.
    xserver.enable = true;

    # Required runtime daemons so GNOME Calendar can sync provider calendars
    # under non-GNOME sessions like Hyprland.
    gnome.gnome-online-accounts.enable = true;
    gnome.evolution-data-server.enable = true;
  };

  # Desktop portal support for screen sharing and file pickers on Wayland.
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  # Prefer native Wayland for Chromium/Electron apps where supported.
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
