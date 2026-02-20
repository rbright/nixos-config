# Omega Home Manager Modules

## Purpose

This directory defines the Home Manager layer for `omega` (user-level packages, desktop behavior, and dotfiles).

## Authoritative Files

- `../home-manager.nix`: top-level Home Manager wiring and import list
- `dotfiles.nix`: symlink map for vendored dotfiles in `dotfiles/`
- Feature modules:
  - `appearance.nix`
  - `brave-profiles.nix`
  - `gcsfuse.nix`
  - `hyprland.nix`
  - `rclone.nix`
  - `thunar.nix`
  - `vicinae.nix`

## Dotfiles Scope

`dotfiles.nix` maps tracked files from `dotfiles/` into `$HOME`.

If you keep editor dotfiles externally (for example via GNU Stow), use a portable workflow:

```sh
cd <dotfiles-repo-root>
STOW_FLAGS="-nv" just install <host>
just install <host>

cd <nixos-config-repo-root>
just switch omega
```

## User-Service Runbooks

### Google Drive via rclone

`rclone.nix` provides `rclone-gdrive.service` (user service).

One-time setup:

```sh
rclone config
```

- Configure a remote named `gdrive`.

Apply + verify:

```sh
just switch omega
systemctl --user daemon-reload
systemctl --user enable --now rclone-gdrive.service
systemctl --user status rclone-gdrive.service --no-pager
ls "$HOME/GoogleDrive"
```

### Cloud Storage via gcsfuse

`gcsfuse.nix` provides `gcsfuse-bucket.service` (user service).

Create config file with placeholders:

```sh
mkdir -p "$HOME/.config/gcsfuse"
cat > "$HOME/.config/gcsfuse/gcs-bucket.env" <<'EOF'
GCS_BUCKET=<bucket-name>
# Optional:
# GCS_KEY_FILE=$HOME/.config/gcloud/<service-account>.json
EOF
chmod 600 "$HOME/.config/gcsfuse/gcs-bucket.env"
```

If using user credentials instead of `GCS_KEY_FILE`:

```sh
gcloud auth application-default login
gcloud auth application-default set-quota-project <project-id>
```

Apply + verify:

```sh
just switch omega
systemctl --user daemon-reload
systemctl --user enable --now gcsfuse-bucket.service
systemctl --user status gcsfuse-bucket.service --no-pager
findmnt "$HOME/<mount-dir>" -o TARGET,SOURCE,FSTYPE,OPTIONS
```

Use the mount directory configured in `gcsfuse.nix` for `<mount-dir>`.

### Hyprland runtime checks

After desktop-related dotfile/module changes:

```sh
just switch omega
hyprctl -j configerrors | jq .
just hypr-smoke
```

For dotfile subtree details, see [`dotfiles/README.md`](dotfiles/README.md).
