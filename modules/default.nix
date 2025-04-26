{ config, pkgs, ... }:

{
  nixpkgs = {
    config = {
      allowBroken = true;
      allowInsecure = false;
      allowUnfree = true;
      allowUnsupportedSystem = true;
    };
  };
}
