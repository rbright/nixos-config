{
  config,
  pkgs,
  user,
  ...
}: let
  additionalFiles = import ./files.nix {inherit config pkgs user;};
in {
  home-manager = {
    useGlobalPkgs = true;

    users.${user} = {
      lib,
      pkgs,
      ...
    }: {
      home = {
        enableNixpkgsReleaseCheck = false;
        file = lib.mkMerge [additionalFiles];
        packages = (pkgs.callPackage ../packages.nix {}) ++ (pkgs.callPackage ./packages.nix {});
        stateVersion = "24.11";
      };

      services.skhd.enable = true;
    };
  };
}
