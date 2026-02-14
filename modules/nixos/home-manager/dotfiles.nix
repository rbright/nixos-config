_:
let
  dotfilesRoot = ./dotfiles/omega;

  recursiveSource = source: {
    inherit source;
    recursive = true;
  };
in
{
  # Migrated from /Users/rbright/Projects/dotfiles (.stow/hosts/omega.packages).
  # Runtime/auth artifacts were intentionally not copied.
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
    ".gitconfig".source = dotfilesRoot + "/git/.gitconfig";
    ".gitignore".source = dotfilesRoot + "/git/.gitignore";

    # github
    ".config/gh/config.yml".source = dotfilesRoot + "/github/.config/gh/config.yml";

    # neovim
    ".config/nvim" = recursiveSource (dotfilesRoot + "/neovim/.config/nvim");

    # profile
    ".profile".source = dotfilesRoot + "/profile/.profile";

    # readline
    ".inputrc".source = dotfilesRoot + "/readline/.inputrc";

    # starship
    ".config/starship.toml".source = dotfilesRoot + "/starship/.config/starship.toml";

    # tmux
    ".config/tmux/tmux.conf".source = dotfilesRoot + "/tmux/.config/tmux/tmux.conf";

    # wezterm
    ".config/wezterm" = recursiveSource (dotfilesRoot + "/wezterm/.config/wezterm");

    # zed
    ".config/zed" = recursiveSource (dotfilesRoot + "/zed/.config/zed");

    # zellij
    ".config/zellij" = recursiveSource (dotfilesRoot + "/zellij/.config/zellij");

    # zsh
    ".zsh" = recursiveSource (dotfilesRoot + "/zsh/.zsh");
    ".zshrc".source = dotfilesRoot + "/zsh/.zshrc";
  };
}
