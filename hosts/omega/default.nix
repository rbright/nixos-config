{
  pkgs,
  user,
  ...
}:
{
  imports = [
    ../../modules
  ];

  home = {
    username = user;
    homeDirectory = "/home/${user}";
    stateVersion = "25.11";
    packages = import ../../modules/packages.nix { inherit pkgs; };
  };

  programs.home-manager.enable = true;

  # Ubuntu is not NixOS, so use the generic Linux target.
  targets.genericLinux.enable = true;

  xdg.enable = true;
}
