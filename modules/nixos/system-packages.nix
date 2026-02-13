{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    bolt
    pciutils
    usbutils
    vim
    wget
  ];
}
