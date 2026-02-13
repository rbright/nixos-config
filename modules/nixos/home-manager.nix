{ user, ... }:
{
  home-manager = {
    # Avoid activation failures when HM starts managing existing dotfiles.
    backupFileExtension = "hm-backup";
    useGlobalPkgs = true;
    useUserPackages = true;

    users.${user} =
      {
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
        };

        xdg.enable = true;
      };
  };
}
