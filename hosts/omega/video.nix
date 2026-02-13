{ config, ... }:
{
  hardware = {
    enableRedistributableFirmware = true;
    graphics.enable = true;

    nvidia = {
      modesetting.enable = true;
      open = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      powerManagement.enable = false;
    };
  };

  # Keep NVIDIA selected as the active X11 driver on this machine.
  services.xserver.videoDrivers = [ "nvidia" ];
}
