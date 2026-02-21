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

      # Vicinae in-app keybinds (not global WM shortcuts).
      keybinds = {
        "open-search-filter" = "control+p";
        "open-settings" = "control+,";
        "toggle-action-panel" = "control+b";
        "action.open" = "control+o";
        "action.refresh" = "control+r";
        "action.copy" = "control+shift+c";
      };

      # Provider/entrypoint controls for the root search menu.
      # Entrypoint IDs for apps are their desktop IDs without `.desktop`.
      providers = {
        applications = {
          preferences.defaultAction = "focus";

          entrypoints = {
            # Hide stock Brave so only profile-specific launchers show in Vicinae.
            "brave-browser".enabled = false;

            "btop".enabled = false;
            "calibre-ebook-edit".enabled = false;
            "gvim".enabled = false;
            "htop".enabled = false;
            "kitty".enabled = false;
            "thunar-bulk-rename".enabled = false;
            "thunar-settings".enabled = false;
            "uuctl".enabled = false;
            "vim".enabled = false;
          };
        };

        # Keep only "Create Task" visible from the Todoist extension provider.
        "@thomaslombart/store.raycast.todoist" = {
          entrypoints = {
            "create-task".enabled = true;
            "home".enabled = false;
            "search".enabled = false;
            "quick-add-task".enabled = false;
            "create-project".enabled = false;
            "menu-bar".enabled = false;
            "show-projects".enabled = false;
            "show-labels".enabled = false;
            "show-filters".enabled = false;
            "unfocus-current-task".enabled = false;
            "open-focused-task".enabled = false;
          };
        };

        # Disable the Window Management provider commands (e.g. Switch Windows).
        wm.enabled = false;
      };

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
      # This reads the same compositor clipboard that `wl-copy` / `wl-paste` use.
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
