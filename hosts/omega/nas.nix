let
  unifiNasHost = "192.168.31.119";
  # UniFi Drive exports shared drives under /var/nfs/shared/<SharedDriveName>.
  unifiNasExport = "/var/nfs/shared/Shared";
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
      "nfsvers=4.1"
      "x-systemd.automount"
      "x-systemd.idle-timeout=10min"
      "x-systemd.device-timeout=10s"
      "x-systemd.mount-timeout=10s"
    ];
  };
}
