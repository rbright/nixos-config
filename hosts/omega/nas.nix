let
  unifiNasHost = "192.168.31.119";
  # Use the exact export path returned by `showmount -e <unifi-host>`.
  unifiNasExport = "/volume/3351ce27-74cc-4650-8150-68d70281a854/.srv/.unifi-drive/Shared/.data";
in
{
  boot.supportedFilesystems = [ "nfs" ];

  fileSystems."/mnt/unifi-drive" = {
    device = "${unifiNasHost}:${unifiNasExport}";
    fsType = "nfs";
    options = [
      "noauto"
      "nofail"
      "_netdev"
      "nfsvers=3"
      "x-systemd.automount"
      "x-systemd.idle-timeout=10min"
      "x-systemd.device-timeout=10s"
      "x-systemd.mount-timeout=10s"
    ];
  };
}
