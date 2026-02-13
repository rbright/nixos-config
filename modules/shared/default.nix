_: {
  imports = [
    ./fonts.nix
    ./nix.nix
  ];

  nixpkgs.config = {
    allowBroken = false;
    allowInsecure = false;
    allowUnfree = true;
    allowUnsupportedSystem = false;
  };
}
