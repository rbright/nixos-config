{
  config,
  pkgs,
  user,
  ...
}:
let
  additionalFiles = import ./files.nix { inherit config pkgs user; };
in
{
  home-manager = {
    useGlobalPkgs = true;

    # Avoid activation failures when HM starts managing existing dotfiles.
    backupFileExtension = "hm-backup";

    users.${user} =
      {
        lib,
        pkgs,
        ...
      }:
      {
        home = {
          enableNixpkgsReleaseCheck = false;
          file = lib.mkMerge [ additionalFiles ];
          packages = (pkgs.callPackage ../shared/packages.nix { }) ++ (pkgs.callPackage ./packages.nix { });
          stateVersion = "24.11";
        };

        programs = {
          git = {
            enable = true;
            settings = {
              commit.gpgSign = true;
              gpg.format = "ssh";

              "gpg \"ssh\"" = {
                allowedSignersFile = "~/.ssh/allowed_signers";
                program = "${pkgs.openssh}/bin/ssh-keygen";
              };

              user = {
                email = "ryan@moonriseconsulting.io";
                name = "Ryan Bright";
                signingKey = "~/.ssh/id_ed25519.pub";
              };
            };
          };

          home-manager.enable = true;
        };

        services.skhd.enable = true;

        xdg.enable = true;
      };
  };
}
