{ pkgs, ... }:
{
  # Keep kitty installed as requested; Hyprland can still default to wezterm.
  programs.kitty.enable = true;

  # Hyprland/Waybar/Mako config is sourced from dotfiles.nix-native files.
  home.packages = with pkgs; [
    btop
    blueman
    gnome-control-center
    grim
    hyprlock
    hyprpaper
    mako
    networkmanagerapplet
    pavucontrol
    slurp
    waybar
    wl-clipboard
    wofi
  ];

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
      cursor-theme = "Bibata-Modern-Ice";
      cursor-size = 24;
      font-name = "Inter 12";
    };
  };

  # Cursor theme for GTK/Wayland apps. Change `name`/`size` here to customize.
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
  };

  home.sessionVariables = {
    GTK_THEME = "catppuccin-mocha-blue-standard";
    XCURSOR_THEME = "Bibata-Modern-Ice";
    XCURSOR_SIZE = "24";
    HYPRCURSOR_THEME = "Bibata-Modern-Ice";
    HYPRCURSOR_SIZE = "24";
  };
}
