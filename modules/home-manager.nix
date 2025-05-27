{
  config,
  pkgs,
  lib,
  user,
  ...
}:

let
  additionalFiles = import ./files.nix { inherit config pkgs user; };
in
{
  home-manager.useGlobalPkgs = true;

  home-manager.users.${user} =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      home.enableNixpkgsReleaseCheck = false;
      home.file = lib.mkMerge [ additionalFiles ];
      home.packages = pkgs.callPackage ./packages.nix { };
      home.stateVersion = "24.11";
    };
}
