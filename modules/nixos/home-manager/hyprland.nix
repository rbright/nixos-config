{ pkgs, ... }:
let
  # GNOME Control Center blocks panel launch outside GNOME/Unity unless
  # XDG_CURRENT_DESKTOP includes GNOME.
  gnomeOnlineAccountsSettings = pkgs.writeShellScriptBin "gnome-online-accounts-settings" ''
    exec env XDG_CURRENT_DESKTOP=GNOME gnome-control-center online-accounts
  '';
in
{
  # Keep kitty installed as requested; Hyprland can still default to wezterm.
  programs.kitty.enable = true;

  # Hyprland/Waybar/Mako config is sourced from dotfiles.nix-native files.
  home = {
    packages =
      with pkgs;
      [
        # wl-clipboard is provided by the shared user package set in modules/nixos/packages.nix.
        btop
        blueman
        evolution-data-server
        gnome-calendar
        gnome-control-center
        gnome-online-accounts
        grim
        hypridle
        hyprlock
        hyprpaper
        hyprpicker
        hyprpwcenter
        mako
        networkmanagerapplet
        pavucontrol
        slurp
        waybar
      ]
      ++ [
        gnomeOnlineAccountsSettings
      ];

    # Cursor theme for GTK/Wayland apps. Change `name`/`size` here to customize.
    pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      package = pkgs.catppuccin-cursors.mochaBlue;
      name = "catppuccin-mocha-blue-cursors";
      size = 24;
    };

    sessionVariables = {
      GTK_THEME = "catppuccin-mocha-blue-standard:dark";
      GTK_APPLICATION_PREFER_DARK_THEME = "1";
      XCURSOR_THEME = "catppuccin-mocha-blue-cursors";
      XCURSOR_SIZE = "24";
      HYPRCURSOR_THEME = "catppuccin-mocha-blue-cursors";
      HYPRCURSOR_SIZE = "24";
    };
  };

}
