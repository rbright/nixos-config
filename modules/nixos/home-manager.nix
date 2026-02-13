{ user, ... }:
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.${user} =
      {
        config,
        pkgs,
        ...
      }:
      {
        home = {
          enableNixpkgsReleaseCheck = false;
          packages = (pkgs.callPackage ../shared/packages.nix { }) ++ (pkgs.callPackage ./packages.nix { });
          stateVersion = "25.11";
        };

        programs = {
          home-manager.enable = true;

          nushell = {
            enable = true;
          };

          zsh = {
            dotDir = config.home.homeDirectory;
            enable = true;
            oh-my-zsh = {
              enable = true;
            };
          };
        };

        xdg.enable = true;
      };
  };
}
