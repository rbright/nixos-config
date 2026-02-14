{ lib, pkgs, ... }:
let
  assignWorkspacesToMonitors = pkgs.writeShellScript "hypr-assign-workspaces-to-monitors" ''
    set -euo pipefail

    monitors_json=""

    # Hyprland may start before both displays are announced.
    for _ in $(seq 1 10); do
      monitors_json="$(hyprctl -j monitors 2>/dev/null || true)"

      if [ -n "$monitors_json" ] && [ "$monitors_json" != "[]" ]; then
        break
      fi

      sleep 0.5
    done

    if [ -z "$monitors_json" ] || [ "$monitors_json" = "[]" ]; then
      exit 0
    fi

    mapfile -t monitor_names < <(
      printf '%s\n' "$monitors_json" | ${pkgs.jq}/bin/jq -r 'sort_by(.id) | .[].name'
    )

    if [ "''${#monitor_names[@]}" -eq 0 ]; then
      exit 0
    fi

    primary_monitor="''${monitor_names[0]}"
    secondary_monitor="''${monitor_names[1]:-''${monitor_names[0]}}"

    for workspace in 1 2 3 4 5; do
      hyprctl dispatch moveworkspacetomonitor "$workspace $primary_monitor" >/dev/null 2>&1 || true
    done

    for workspace in 6 7 8 9 10; do
      hyprctl dispatch moveworkspacetomonitor "$workspace $secondary_monitor" >/dev/null 2>&1 || true
    done
  '';
in
{
  # Keep kitty installed (fallback/compatibility), but prefer wezterm in keybinds.
  programs.kitty = {
    enable = true;
    settings = {
      confirm_os_window_close = 0;
      enable_audio_bell = false;
    };
  };

  home.packages = with pkgs; [
    wofi
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = lib.mkForce false;
    xwayland.enable = true;

    # Omarchy-style composition: keep the root file tiny and source focused files.
    extraConfig = ''
      source = ~/.config/hypr/monitors.conf
      source = ~/.config/hypr/envs.conf
      source = ~/.config/hypr/input.conf
      source = ~/.config/hypr/looknfeel.conf
      source = ~/.config/hypr/workspaces.conf
      source = ~/.config/hypr/windows.conf
      source = ~/.config/hypr/bindings.conf
      source = ~/.config/hypr/autostart.conf
    '';
  };

  xdg.configFile = {
    "hypr/monitors.conf".text = ''
      # List your outputs with: hyprctl monitors
      monitor = ,preferred,auto,1
    '';

    "hypr/envs.conf".text = ''
      env = XCURSOR_SIZE,24
      env = NIXOS_OZONE_WL,1
      env = ELECTRON_OZONE_PLATFORM_HINT,wayland
      env = MOZ_ENABLE_WAYLAND,1
      env = XDG_CURRENT_DESKTOP,Hyprland
      env = XDG_SESSION_DESKTOP,Hyprland
    '';

    "hypr/input.conf".text = ''
      input {
        kb_layout = us
        follow_mouse = 1

        touchpad {
          natural_scroll = true
        }
      }

      gestures {
        workspace_swipe = true
      }
    '';

    "hypr/looknfeel.conf".text = ''
      $activeBorderColor = rgba(89b4faff)
      $inactiveBorderColor = rgba(585b70aa)

      general {
        gaps_in = 5
        gaps_out = 8
        border_size = 2
        col.active_border = $activeBorderColor
        col.inactive_border = $inactiveBorderColor
        layout = dwindle
      }

      decoration {
        rounding = 8
      }

      dwindle {
        preserve_split = true
        pseudotile = true
        force_split = 2
      }

      misc {
        disable_hyprland_logo = true
        force_default_wallpaper = 0
      }
    '';

    "hypr/workspaces.conf".text = ''
      workspace = 1, persistent:true
      workspace = 2, persistent:true
      workspace = 3, persistent:true
      workspace = 4, persistent:true
      workspace = 5, persistent:true
      workspace = 6, persistent:true
      workspace = 7, persistent:true
      workspace = 8, persistent:true
      workspace = 9, persistent:true
      workspace = 10, persistent:true
    '';

    "hypr/windows.conf".text = ''
      # Use `hyprctl clients` to verify classes and tune these over time.
      windowrulev2 = workspace 1, class:^(firefox)$
      windowrulev2 = workspace 2, class:^(Brave-browser|google-chrome|Google-chrome)$
      windowrulev2 = workspace 3, class:^(code-url-handler|Code)$
      windowrulev2 = workspace 7, class:^(1Password)$
      windowrulev2 = workspace 8, class:^(Slack)$
      windowrulev2 = workspace 9, class:^(discord)$
      windowrulev2 = workspace 10, class:^(obsidian)$
    '';

    "hypr/bindings.conf".text = ''
      $mod = SUPER
      $terminal = wezterm
      $menu = wofi --show drun

      bind = $mod, RETURN, exec, $terminal
      bind = $mod, D, exec, $menu

      bind = $mod, LEFT, movefocus, l
      bind = $mod, RIGHT, movefocus, r
      bind = $mod, UP, movefocus, u
      bind = $mod, DOWN, movefocus, d

      bind = $mod SHIFT, LEFT, swapwindow, l
      bind = $mod SHIFT, RIGHT, swapwindow, r
      bind = $mod SHIFT, UP, swapwindow, u
      bind = $mod SHIFT, DOWN, swapwindow, d

      bind = $mod, W, killactive,
      bind = $mod, T, togglefloating,
      bind = $mod, F, fullscreen, 0
      bind = $mod ALT, F, fullscreen, 1
      bind = $mod, P, pseudo,
      bind = $mod, J, togglesplit,

      bind = $mod, code:10, workspace, 1
      bind = $mod, code:11, workspace, 2
      bind = $mod, code:12, workspace, 3
      bind = $mod, code:13, workspace, 4
      bind = $mod, code:14, workspace, 5
      bind = $mod, code:15, workspace, 6
      bind = $mod, code:16, workspace, 7
      bind = $mod, code:17, workspace, 8
      bind = $mod, code:18, workspace, 9
      bind = $mod, code:19, workspace, 10

      bind = $mod SHIFT, code:10, movetoworkspace, 1
      bind = $mod SHIFT, code:11, movetoworkspace, 2
      bind = $mod SHIFT, code:12, movetoworkspace, 3
      bind = $mod SHIFT, code:13, movetoworkspace, 4
      bind = $mod SHIFT, code:14, movetoworkspace, 5
      bind = $mod SHIFT, code:15, movetoworkspace, 6
      bind = $mod SHIFT, code:16, movetoworkspace, 7
      bind = $mod SHIFT, code:17, movetoworkspace, 8
      bind = $mod SHIFT, code:18, movetoworkspace, 9
      bind = $mod SHIFT, code:19, movetoworkspace, 10

      bind = $mod SHIFT ALT, LEFT, movecurrentworkspacetomonitor, l
      bind = $mod SHIFT ALT, RIGHT, movecurrentworkspacetomonitor, r
      bind = $mod SHIFT ALT, UP, movecurrentworkspacetomonitor, u
      bind = $mod SHIFT ALT, DOWN, movecurrentworkspacetomonitor, d

      bind = $mod, TAB, workspace, e+1
      bind = $mod SHIFT, TAB, workspace, e-1
      bind = $mod, mouse_down, workspace, e+1
      bind = $mod, mouse_up, workspace, e-1

      bindm = $mod, mouse:272, movewindow
      bindm = $mod, mouse:273, resizewindow
    '';

    "hypr/autostart.conf".text = ''
      exec-once = systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
      exec-once = dbus-update-activation-environment --systemd --all
      exec-once = ${assignWorkspacesToMonitors}
    '';
  };
}
