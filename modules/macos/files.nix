_:
let
  sharedFiles = import ../shared/home-manager/dotfiles.nix;
  dotfilesRoot = ./dotfiles;

  recursiveSource = source: {
    inherit source;
    recursive = true;
  };

  macosFiles = {
    # aerospace
    ".config/aerospace/aerospace.toml".source =
      dotfilesRoot + "/aerospace/.config/aerospace/aerospace.toml";

    # espanso
    "Library/Application Support/espanso" = recursiveSource (
      dotfilesRoot + "/espanso/Library/Application Support/espanso"
    );

    # karabiner
    ".config/karabiner/karabiner.json".source =
      dotfilesRoot + "/karibiner/.config/karabiner/karabiner.json";

    # macmon
    ".config/macmon.json".source = dotfilesRoot + "/macmon/.config/macmon.json";

    # procs
    "Library/Preferences/com.github.dalance.procs/config.toml".source =
      dotfilesRoot + "/procs/Library/Preferences/com.github.dalance.procs/config.toml";

    # skhd
    ".config/skhd/skhdrc".source = dotfilesRoot + "/skhd/.config/skhd/skhdrc";

    # tableplus
    "Library/Application Support/com.tinyapp.TablePlus/Themes/Catppuccin Mocha.tableplustheme".source =
      dotfilesRoot + "/tableplus/themes/Catppuccin Mocha.tableplustheme";

    # xcode
    "Library/Developer/Xcode/UserData/FontAndColorThemes/Catppuccin Mocha.xccolortheme".source =
      dotfilesRoot
      + "/xcode/Library/Developer/Xcode/UserData/FontAndColorThemes/Catppuccin Mocha.xccolortheme";
  };
in
sharedFiles // macosFiles
