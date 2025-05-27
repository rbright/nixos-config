################################################################################
# macOS Host Configuration
#
# Configuration options at https://daiderd.com/nix-darwin/manual/index.html
################################################################################

{ config, pkgs, ... }:

let
  user = "rbright";
in

{
  imports = [
    ../modules/home-manager.nix
    ../modules
    ../modules/darwin
  ];

  ##############################################################################
  # Nix
  ##############################################################################

  nix.enable = false;
  nix.package = pkgs.nix;

  nix.settings = {
    trusted-users = [
      "@admin"
      user
    ];
    substituters = [
      "https://nix-community.cachix.org"
      "https://cache.nixos.org"
    ];
    trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
  };

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  system.checks.verifyNixPath = false;
  system.primaryUser = user;
  system.stateVersion = 5;

  system.activationScripts.postActivation.text = ''
    # Avoid logout/login cycle to apply settings
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';

  environment.shells = [
    "/Users/rbright/.nix-profile/bin/nu"
  ];

  environment.systemPackages =
    with pkgs;
    [

    ]
    ++ (import ../modules/packages.nix { inherit pkgs; });
}
