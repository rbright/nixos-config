_: {
  # Keep kitty installed as requested.
  programs.kitty.enable = true;

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;

    # Minimal, safe baseline to ensure Hyprland starts.
    settings = {
      "$mod" = "SUPER";

      bind = [
        "$mod, RETURN, exec, kitty"
        "$mod SHIFT, Q, killactive,"
        "$mod SHIFT, M, exit,"
      ];
    };
  };
}
