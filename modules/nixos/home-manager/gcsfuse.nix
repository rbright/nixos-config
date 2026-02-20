{ pkgs, ... }:
let
  gcsfuseConfigPath = "%h/.config/gcsfuse/gcs-bucket.env";
  gcsfuseMountPoint = "%h/fp-state-downloads";

  gcsfusePrepareMountScript = pkgs.writeShellScript "gcsfuse-bucket-prepare-mount" ''
    set -euo pipefail

    mount_point="$1"

    if ! ${pkgs.coreutils}/bin/mkdir -p "$mount_point" 2>/dev/null; then
      ${pkgs.fuse3}/bin/fusermount3 -uz "$mount_point" || true
      ${pkgs.coreutils}/bin/mkdir -p "$mount_point"
    fi
  '';

  gcsfuseStartScript = pkgs.writeShellScript "gcsfuse-bucket-start" ''
    set -euo pipefail

    : "''${GCS_BUCKET:?Set GCS_BUCKET in ${gcsfuseConfigPath}}"

    if [[ -n "''${GCS_KEY_FILE:-}" ]]; then
      exec ${pkgs.gcsfuse}/bin/gcsfuse \
        --foreground \
        --implicit-dirs \
        --key-file "''${GCS_KEY_FILE}" \
        "''${GCS_BUCKET}" \
        "$1"
    fi

    exec ${pkgs.gcsfuse}/bin/gcsfuse \
      --foreground \
      --implicit-dirs \
      "''${GCS_BUCKET}" \
      "$1"
  '';
in
{
  # Auto-mount a single GCS bucket when the per-user config file exists.
  systemd.user.services.gcsfuse-bucket = {
    Unit = {
      Description = "Mount a Google Cloud Storage bucket via gcsfuse";
      After = [
        "graphical-session.target"
        "network-online.target"
      ];
      Wants = [ "network-online.target" ];
      ConditionPathExists = gcsfuseConfigPath;
    };

    Service = {
      Type = "simple";
      EnvironmentFile = gcsfuseConfigPath;
      ExecStartPre = "${gcsfusePrepareMountScript} ${gcsfuseMountPoint}";
      ExecStart = "${gcsfuseStartScript} ${gcsfuseMountPoint}";
      ExecStop = "-${pkgs.fuse3}/bin/fusermount3 -uz ${gcsfuseMountPoint}";
      Restart = "on-failure";
      RestartSec = "5s";
    };

    Install.WantedBy = [ "default.target" ];
  };
}
