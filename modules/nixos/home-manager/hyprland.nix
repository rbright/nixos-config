{ pkgs, ... }:
{
  # Keep kitty installed as requested; Hyprland can still default to wezterm.
  programs.kitty.enable = true;

  # Hyprland/Waybar/Mako config is sourced from dotfiles.nix-native files.
  home = {
    packages = with pkgs; [
      btop
      blueman
      gnome-calendar
      gnome-control-center
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
      wl-clipboard
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
      GTK_THEME = "catppuccin-mocha-blue-standard";
      XCURSOR_THEME = "catppuccin-mocha-blue-cursors";
      XCURSOR_SIZE = "24";
      HYPRCURSOR_THEME = "catppuccin-mocha-blue-cursors";
      HYPRCURSOR_SIZE = "24";
    };
  };

  # Keep GTK/portal dialogs in dark Catppuccin mode (no light save dialogs).
  gtk = {
    enable = true;
    theme = {
      package = pkgs.catppuccin-gtk.override {
        accents = [ "blue" ];
        size = "standard";
        variant = "mocha";
      };
      name = "catppuccin-mocha-blue-standard";
    };
    iconTheme = {
      package = pkgs.catppuccin-papirus-folders;
      name = "Papirus-Dark";
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "catppuccin-mocha-blue-standard";
      icon-theme = "Papirus-Dark";
      cursor-theme = "catppuccin-mocha-blue-cursors";
      cursor-size = 24;
      font-name = "Inter 12";
    };
  };

}
