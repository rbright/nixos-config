{ pkgs, ... }:
let
  catppuccinGtk = pkgs.catppuccin-gtk.override {
    accents = [ "blue" ];
    size = "standard";
    variant = "mocha";
  };
  hyprlockWallpaper = ./home-manager/dotfiles/hypr/.config/hypr/wallpapers/cat-waves-mocha.png;
  # Hide the non-UWSM Hyprland session in ReGreet so only one Hyprland session
  # is presented at login.
  regreetSessionOverrides = pkgs.writeTextDir "share/wayland-sessions/hyprland.desktop" ''
    [Desktop Entry]
    Name=Hyprland
    Type=Application
    Hidden=true
    NoDisplay=true
    Exec=/run/current-system/sw/bin/false
  '';
in
{
  programs = {
    # Use Hyprland as the compositor/session manager.
    hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };

    # Needed by many GTK/GNOME settings and apps for persisted preferences.
    dconf.enable = true;
    regreet = {
      enable = true;
      theme = {
        package = catppuccinGtk;
        name = "catppuccin-mocha-blue-standard";
      };
      iconTheme = {
        package = pkgs.catppuccin-papirus-folders;
        name = "Papirus-Dark";
      };
      cursorTheme = {
        package = pkgs.catppuccin-cursors.mochaBlue;
        name = "catppuccin-mocha-blue-cursors";
      };
      font = {
        package = pkgs.ibm-plex;
        name = "IBM Plex Sans";
        size = 16;
      };
      settings = {
        GTK.application_prefer_dark_theme = true;
        appearance.greeting_msg = "Welcome back";
        background = {
          path = "${hyprlockWallpaper}";
          # ReGreet expects GTK enum casing, e.g. Cover/Contain/Fill/ScaleDown.
          fit = "Cover";
        };
        commands = {
          reboot = [
            "systemctl"
            "reboot"
          ];
          poweroff = [
            "systemctl"
            "poweroff"
          ];
        };
      };
      extraCss = ''
        * {
          font-family: "IBM Plex Sans", "Font Awesome 7 Free", "Font Awesome 7 Brands";
        }

        window {
          background: transparent;
        }

        /* ReGreet frames use the .background class. */
        frame.background {
          background-color: rgba(30, 30, 46, 0.72);
          border: 2px solid rgba(137, 180, 250, 0.4);
          border-radius: 18px;
          padding: 10px;
        }

        label {
          color: #cdd6f4;
        }

        entry,
        passwordentry,
        combobox,
        button {
          background-color: rgba(30, 30, 46, 0.86);
          border: 2px solid #89b4fa;
          border-radius: 12px;
          color: #cdd6f4;
        }

        entry,
        passwordentry {
          min-height: 44px;
          padding-left: 10px;
          padding-right: 10px;
        }

        entry:focus,
        passwordentry:focus-within,
        combobox:focus-within {
          border-color: #a6e3a1;
        }

        button:hover {
          background-color: rgba(49, 50, 68, 0.92);
        }

        button.suggested-action {
          background-color: #89b4fa;
          border-color: #89b4fa;
          color: #1e1e2e;
        }

        button.destructive-action {
          background-color: #f38ba8;
          border-color: #f38ba8;
          color: #1e1e2e;
        }

        /* Keep clock visible but less oversized than defaults. */
        #clock {
          color: #cdd6f4;
          font-size: 80px;
          font-weight: 700;
        }

        #date {
          color: #bac2de;
          font-size: 24px;
        }

        infobar.error label {
          color: #f9e2af;
        }
      '';
    };
  };

  services = {
    # Use greetd + regreet as a lightweight login manager for Hyprland.
    greetd = {
      enable = true;
      settings.default_session.user = "greeter";
    };

    # Power management daemon required by many desktop components.
    upower.enable = true;

    # Disable X11 desktop sessions; Hyprland runs on Wayland.
    xserver.enable = false;

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

  # Ensure ReGreet sees our hidden-session override first, then the normal
  # system session directory.
  systemd.services.greetd.environment.XDG_DATA_DIRS =
    "${regreetSessionOverrides}/share:/run/current-system/sw/share";
}
