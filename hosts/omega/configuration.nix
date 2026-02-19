_: {
  imports = [
    ./bluetooth.nix
    ./boot.nix
    ./hardware-configuration.nix
    ./nas.nix
    ./speech.nix
    ./thunderbolt.nix
    ./video.nix
  ];

  system.stateVersion = "25.11";
}
