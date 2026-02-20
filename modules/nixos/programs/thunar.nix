{ pkgs, user, ... }:
{
  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-archive-plugin
      thunar-volman
    ];
  };

  # Seed a default Places shortcut in Thunar for the gcsfuse mount.
  environment.etc."xdg/gtk-3.0/bookmarks".text =
    "file:///home/${user}/fp-state-downloads State Downloads\n";

  services = {
    gvfs.enable = true;
    tumbler.enable = true;
  };
}
