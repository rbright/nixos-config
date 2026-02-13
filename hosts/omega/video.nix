{ config, ... }:
{
  # NVIDIA-specific variables recommended for Wayland compositors.
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };

  hardware = {
    enableRedistributableFirmware = true;
    graphics.enable = true;

    # RTX 50-series requires the open NVIDIA kernel module path.
    nvidia = {
      modesetting.enable = true;
      open = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      powerManagement.enable = false;
    };
  };

  # Keep NVIDIA selected as the active graphics driver for this host.
  services.xserver.videoDrivers = [ "nvidia" ];
}
