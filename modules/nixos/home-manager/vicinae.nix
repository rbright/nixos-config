{
  pkgs,
  vicinaeExtensions,
  ...
}:
{
  programs.vicinae = {
    enable = true;

    systemd = {
      enable = true;
      autoStart = true;
    };

    settings = {
      close_on_focus_loss = true;
      consider_preedit = true;
      favicon_service = "twenty";
      pop_to_root_on_close = true;
      search_files_in_root = true;

      font.normal = {
        size = 14;
        family = "IBM Plex Sans";
      };

      theme = {
        light = {
          name = "catppuccin-mocha";
          icon_theme = "default";
        };
        dark = {
          name = "catppuccin-mocha";
          icon_theme = "default";
        };
      };

      launcher_window = {
        opacity = 1.00;
        layer_shell.enabled = true;
      };

      # Keep clipboard history pinned in root for quicker access.
      favorites = [ "clipboard:history" ];
    };

    extensions = with vicinaeExtensions.packages.${pkgs.stdenv.hostPlatform.system}; [
      bluetooth
      nix
      power-profile
    ];

    themes.catppuccin-mocha = {
      meta = {
        version = 1;
        name = "Catppuccin Mocha";
        description = "Cozy feeling with color-rich accents";
        variant = "dark";
        inherits = "vicinae-dark";
      };

      colors = {
        core = {
          background = "#1E1E2E";
          foreground = "#CDD6F4";
          secondary_background = "#181825";
          border = "#313244";
          accent = "#89B4FA";
        };
        accents = {
          blue = "#89B4FA";
          green = "#A6E3A1";
          magenta = "#F5C2E7";
          orange = "#FAB387";
          purple = "#CBA6F7";
          red = "#F38BA8";
          yellow = "#F9E2AF";
          cyan = "#94E2D5";
        };
      };
    };
  };
}
