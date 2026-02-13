{ pkgs, user, ... }:
{
  nix = {
    enable = false;
    package = pkgs.nix;
    settings.trusted-users = [
      "@admin"
      user
    ];
  };
}
