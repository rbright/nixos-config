{ pkgs, ... }:
{
  # Use Hyprland as the compositor/session manager.
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  services = {
    # Keep GDM as the login manager, but run Wayland sessions.
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };

    # Disable X11 desktop sessions; Hyprland runs on Wayland.
    xserver.enable = false;
  };

  # Desktop portal support for screen sharing and file pickers on Wayland.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  # Prefer native Wayland for Chromium/Electron apps where supported.
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
