{ pkgs, ... }:
{
  boot = {
    kernelPackages = pkgs.linuxPackages_6_18;

    kernelParams = [
      "usbcore.autosuspend=-1"
      "pcie_aspm=off"
    ];

    loader.efi.canTouchEfiVariables = true;
    loader.systemd-boot.enable = true;
  };
}
