################################################################################
# macOS Host Configuration
#
# Configuration options at https://daiderd.com/nix-darwin/manual/index.html
################################################################################

_: {
  imports = [
    ./activation.nix
    ./applications
    ./control-center.nix
    ./desktop.nix
    ./dock
    ./environment.nix
    ./finder.nix
    ./home-manager.nix
    ./homebrew
    ./keyboard.nix
    ./language-region.nix
    ./launch-services.nix
    ./login-window.nix
    ./menu-clock.nix
    ./miscellaneous.nix
    ./mouse.nix
    ./networking.nix
    ./nix.nix
    ./remote-access.nix
    ./screen-saver.nix
    ./security.nix
    ./software-update.nix
    ./sound.nix
    ./startup.nix
    ./system.nix
    ./trackpad.nix
    ./user.nix
    ./windows.nix
  ];
}
