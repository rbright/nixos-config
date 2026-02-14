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
    # Keep GDM as the login manager, but run Wayland sessions.
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };

    # Power management daemon required by many desktop components.
    upower.enable = true;

    # Disable X11 desktop sessions; Hyprland runs on Wayland.
    xserver.enable = false;
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
