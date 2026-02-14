{ pkgs, ... }:
{
  # Keep kitty installed as requested; Hyprland can still default to wezterm.
  programs.kitty.enable = true;

  # Hyprland/Waybar/Mako config is sourced from dotfiles.nix-native files.
  home.packages = with pkgs; [
    gnome-control-center
    grim
    mako
    slurp
    waybar
    wl-clipboard
    wofi
  ];
}
