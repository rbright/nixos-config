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
  home-manager = {
    useGlobalPkgs = true;
    users.${user} =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        home = {
          enableNixpkgsReleaseCheck = false;
          packages = pkgs.callPackage ./packages.nix { };
          file = lib.mkMerge [
            additionalFiles
          ];
          stateVersion = "24.11";
        };
        programs = { };
      };
  };
}
