_: {
  imports = [
    ./bluetooth.nix
    ./boot.nix
    ./hardware-configuration.nix
    ./thunderbolt.nix
    ./video.nix
  ];

  system.stateVersion = "25.11";
}
