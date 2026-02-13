{ config, user, ... }:
{
  # Allow login shells to use Nushell from the user profile.
  environment.shells = [
    "${config.users.users.${user}.home}/.nix-profile/bin/nu"
  ];
}
