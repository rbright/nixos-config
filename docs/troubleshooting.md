# Troubleshooting

## `just build lambda` fails on Linux

Expected when no Darwin builder is available (`aarch64-darwin` required).

Use:

```sh
just build omega
```

for Linux-side validation, and run `just build lambda` on macOS.

## `just hypr-smoke` fails immediately

Common cause: command not run inside an active Hyprland session.

Quick checks:

```sh
hyprctl -j version
hyprctl -j configerrors | jq .
```

Then rerun:

```sh
just hypr-smoke
```

## `just lint` reports failures

Run formatting check explicitly:

```sh
just fmt-check
```

Then inspect tool-specific output from:

- `statix`
- `deadnix`
- `nixfmt --check`

## User service mount/unit won’t start on `omega`

For `systemd --user` services (for example rclone/gcsfuse):

```sh
systemctl --user daemon-reload
systemctl --user status <service-name> --no-pager
journalctl --user -u <service-name> -n 100 --no-pager
```

Validate required env/config files exist and use placeholders in docs as needed (`<bucket-name>`, `<project-id>`, `<mount-dir>`).

## Links in docs are broken

Run:

```sh
python3 ~/.agents/skills/update-docs/check-doc-links.py
```

Fix reported relative links and rerun until clean.
