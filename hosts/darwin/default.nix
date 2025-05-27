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
}:

{
  imports = [
    ../../modules/darwin
    ../../modules/home-manager.nix
    ../../modules
  ];

  ##############################################################################
  # Nix
  ##############################################################################

  # Disable Nix
  nix.enable = false;

  # Set Nix package
  nix.package = pkgs.nix;

  nix.settings = {
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
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # Disable Nix path verification
  system.checks.verifyNixPath = false;

  # Explicitly set the primary user
  system.primaryUser = user;

  # Set the system state version
  # NOTE: This should not be changed
  system.stateVersion = 5;

  # Setup the user
  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
    isHidden = false;
    shell = pkgs.zsh;
  };

  # Set the system shells
  environment.shells = [
    "${config.users.users.${user}.home}/.nix-profile/bin/nu"
  ];

  # Activate settings after activation
  system.activationScripts.postActivation.text = ''
    # Avoid logout/login cycle to apply settings
    sudo -u ${user} /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';

  # Set the system packages
  environment.systemPackages =
    with pkgs;
    [

    ]
    ++ (import ../../modules/packages.nix { inherit pkgs; });
}
