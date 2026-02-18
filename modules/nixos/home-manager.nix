{
  user,
  nixPiAgent,
  vicinaeExtensions,
  ...
}:
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit vicinaeExtensions;
    };

    # Avoid activation failures when HM starts managing existing dotfiles.
    backupFileExtension = "hm-backup";

    users.${user} =
      {
        pkgs,
        ...
      }:
      {
        imports = [
          ./home-manager/appearance.nix
          ./home-manager/brave-profiles.nix
          ./home-manager/hyprland.nix
          ./home-manager/rclone.nix
          ./home-manager/thunar.nix
          ./home-manager/vicinae.nix
          ./home-manager/dotfiles.nix
        ];

        home = {
          enableNixpkgsReleaseCheck = false;
          packages =
            (pkgs.callPackage ../shared/packages.nix { })
            ++ (pkgs.callPackage ./packages.nix { inherit nixPiAgent; });
          stateVersion = "25.11";
        };

        programs = {
          home-manager.enable = true;
        };

        xdg.enable = true;
      };
  };
}
