_:
let
  dotfilesRoot = ./dotfiles;

  recursiveSource = source: {
    inherit source;
    recursive = true;
  };
in
{
  home.file = {
    # atuin
    ".config/atuin/config.toml".source = dotfilesRoot + "/atuin/.config/atuin/config.toml";
    ".local/share/atuin/init.nu".source = dotfilesRoot + "/atuin/.local/share/atuin/init.nu";

    # btop
    ".config/btop" = recursiveSource (dotfilesRoot + "/btop/.config/btop");

    # carapace
    ".config/carapace/bridge/zsh/.zshrc".source =
      dotfilesRoot + "/carapace/.config/carapace/bridge/zsh/.zshrc";

    # curl
    ".curlrc".source = dotfilesRoot + "/curl/.curlrc";

    # git
    ".gitignore".source = dotfilesRoot + "/git/.gitignore";

    # github
    ".config/gh/config.yml".source = dotfilesRoot + "/github/.config/gh/config.yml";

    # hypr
    ".config/hypr" = recursiveSource (dotfilesRoot + "/hypr/.config/hypr");

    # mako
    ".config/mako/config".source = dotfilesRoot + "/mako/.config/mako/config";

    # nushell
    ".config/nushell" = recursiveSource (dotfilesRoot + "/nushell/.config/nushell");

    # profile
    ".profile".source = dotfilesRoot + "/profile/.profile";

    # readline
    ".inputrc".source = dotfilesRoot + "/readline/.inputrc";

    # starship
    ".config/starship.toml".source = dotfilesRoot + "/starship/.config/starship.toml";

    # tmux
    ".config/tmux/tmux.conf".source = dotfilesRoot + "/tmux/.config/tmux/tmux.conf";

    # waybar
    ".config/waybar" = recursiveSource (dotfilesRoot + "/waybar/.config/waybar");

    # wezterm
    ".config/wezterm" = recursiveSource (dotfilesRoot + "/wezterm/.config/wezterm");

    # zellij
    ".config/zellij" = recursiveSource (dotfilesRoot + "/zellij/.config/zellij");

    # zsh
    ".zsh" = recursiveSource (dotfilesRoot + "/zsh/.zsh");
    ".zshrc".source = dotfilesRoot + "/zsh/.zshrc";
  };
}
