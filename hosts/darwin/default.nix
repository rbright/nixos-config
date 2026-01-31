################################################################################
# macOS Host Configuration
#
# Configuration options at https://daiderd.com/nix-darwin/manual/index.html
################################################################################
{
  config,
  pkgs,
  user,
  ...
}: {
  imports = [
    ../../modules
    ../../modules/darwin
  ];

  nix = {
    ##############################################################################
    # Nix
    ##############################################################################

    # Disable Nix
    enable = false;

    # Set Nix package
    package = pkgs.nix;

    settings = {
      substituters = [
        "https://nix-community.cachix.org"
        "https://cache.nixos.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
      trusted-users = [
        "@admin"
        user
      ];
    };

    # Enable Flakes
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  system = {
    # Disable Nix path verification
    checks.verifyNixPath = false;

    # Explicitly set the primary user
    primaryUser = user;

    # Set the system state version
    # NOTE: This should not be changed
    stateVersion = 5;

    # Activate settings after activation
    activationScripts.postActivation.text = ''
      # Avoid logout/login cycle to apply settings
      sudo -u ${user} /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';
  };

  # Setup the user
  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
    isHidden = false;
    shell = pkgs.zsh;
  };

  environment = {
    # Set the system shells
    shells = [
      "${config.users.users.${user}.home}/.nix-profile/bin/nu"
    ];

    # Set the system packages
    systemPackages =
      (import ../../modules/packages.nix {inherit pkgs;})
      ++ (import ../../modules/darwin/packages.nix {inherit pkgs;});
  };
}
