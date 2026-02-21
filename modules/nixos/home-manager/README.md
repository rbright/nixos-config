# Omega Home Manager Modules

## Purpose

This directory defines the Home Manager layer for `omega` (user-level packages, desktop behavior, and dotfiles).

## Authoritative Files

- `../home-manager.nix`: top-level Home Manager wiring and import list
- `dotfiles.nix`: NixOS-only `home.file` overlay merged with shared dotfiles mapping
- Feature modules:
  - `appearance.nix`
  - `brave-profiles.nix`
  - `gcsfuse.nix`
  - `hyprland.nix`
  - `rclone.nix`
  - `thunar.nix`
  - `thunderbird.nix`
  - `vicinae.nix`

## Dotfiles Scope

- Shared cross-OS files are sourced from `modules/shared/home-manager/dotfiles/`.
- NixOS-only files are sourced from `modules/nixos/home-manager/dotfiles/` and merged by `dotfiles.nix`.

`neovim` and `zed` remain intentionally external to this repository and are managed independently of Nix.

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

### Thunderbird theme wiring

`thunderbird.nix` links repo-managed CSS into the default Thunderbird profile
(`Default=1` in `~/.thunderbird/profiles.ini`) during Home Manager activation.

Apply + verify:

```sh
just switch omega
ls -l "$HOME/.thunderbird"/*/chrome/userChrome.css
ls -l "$HOME/.thunderbird"/*/chrome/userContent.css
```

### Vicinae app visibility and in-app keybinds

`vicinae.nix` sets launcher behavior via `programs.vicinae.settings`.

Examples in this repo:

- Hide an app entry from root search via `settings.providers.applications.entrypoints.<app-id>.enabled = false`.
- Set in-app shortcuts via `settings.keybinds` (these are Vicinae UI shortcuts, not global Hyprland binds).

To find an app entrypoint ID, use the desktop ID without `.desktop` (for example `brave-browser`).

For dotfile subtree details, see [`dotfiles/README.md`](dotfiles/README.md).
