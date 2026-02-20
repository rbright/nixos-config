_:
let
  sharedFiles = import ../../shared/home-manager/dotfiles.nix;
  dotfilesRoot = ./dotfiles;

  recursiveSource = source: {
    inherit source;
    recursive = true;
  };

  nixosFiles = {
    # hypr
    ".config/hypr" = recursiveSource (dotfilesRoot + "/hypr/.config/hypr");

    # mako
    ".config/mako/config".source = dotfilesRoot + "/mako/.config/mako/config";

    # sotto
    ".config/sotto/config.jsonc".source = dotfilesRoot + "/sotto/.config/sotto/config.jsonc";

    # waybar
    ".config/waybar" = recursiveSource (dotfilesRoot + "/waybar/.config/waybar");
  };
in
{
  home.file = sharedFiles // nixosFiles;
}
