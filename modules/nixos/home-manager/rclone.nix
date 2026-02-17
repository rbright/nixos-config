{ pkgs, ... }:
let
  rcloneRemote = "gdrive";
  rcloneConfigPath = "%h/.config/rclone/rclone.conf";
  rcloneMountPoint = "%h/GoogleDrive";
in
{
  home.packages = [ pkgs.rclone ];

  # Keep Google Drive access independent of GOA/GVFS availability.
  systemd.user.services.rclone-gdrive = {
    Unit = {
      Description = "Mount Google Drive via rclone";
      After = [
        "graphical-session.target"
        "network-online.target"
      ];
      Wants = [ "network-online.target" ];
      ConditionPathExists = rcloneConfigPath;
    };

    Service = {
      Type = "simple";
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${rcloneMountPoint}";
      ExecStart = ''
        ${pkgs.rclone}/bin/rclone mount ${rcloneRemote}: ${rcloneMountPoint} \
          --config ${rcloneConfigPath} \
          --vfs-cache-mode full \
          --vfs-cache-max-age 24h \
          --dir-cache-time 72h \
          --poll-interval 15s \
          --umask 022
      '';
      ExecStop = "${pkgs.fuse3}/bin/fusermount3 -u ${rcloneMountPoint}";
      Restart = "on-failure";
      RestartSec = "5s";
    };

    Install.WantedBy = [ "default.target" ];
  };
}
