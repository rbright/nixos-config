{ lib, user, ... }:
{
  # Enable Docker Engine (dockerd) for local Compose workflows.
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };

  # Allow the primary user to run Docker without sudo.
  users.users.${user}.extraGroups = lib.mkAfter [
    "docker"
  ];
}
