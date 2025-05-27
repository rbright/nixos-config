{
  pkgs,
  ...
}:

{
  imports = [
    # Core
    ./control-center.nix
    ./desktop.nix
    ./dock.nix
    ./finder.nix
    ./fonts.nix
    ./keyboard.nix
    ./language-region.nix
    ./launch-services.nix
    ./login-window.nix
    ./menu-clock.nix
    ./miscellaneous.nix
    ./mouse.nix
    ./networking.nix
    ./screen-saver.nix
    ./software-update.nix
    ./sound.nix
    ./startup.nix
    ./trackpad.nix
    ./windows.nix

    # Applications
    ./applications

    # Homebrew
    ./homebrew
  ];
}
