{ lib, user, ... }:
{
  # Enable Docker Engine (dockerd) for local Compose workflows.
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };

  # Required for NVIDIA GPU access from OCI containers (docker --gpus ...).
  hardware.nvidia-container-toolkit.enable = true;

  # Allow the primary user to run Docker without sudo.
  users.users.${user}.extraGroups = lib.mkAfter [
    "docker"
  ];
}
