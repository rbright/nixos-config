{ pkgs, ... }:
{
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
      text-scaling-factor = 1.0;
      font-name = "IBM Plex Sans 11";
    };
  };
}
