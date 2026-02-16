#!/usr/bin/env sh
set -eu

# Restart UI daemons first, then reload Hyprland bindings/config.
pkill -x .waybar-wrapped >/dev/null 2>&1 || true
pkill -x waybar >/dev/null 2>&1 || true
pkill -x mako >/dev/null 2>&1 || true
sleep 0.2
if command -v setsid >/dev/null 2>&1; then
  setsid -f waybar >/tmp/waybar.log 2>&1
  setsid -f mako >/tmp/mako.log 2>&1
else
  nohup waybar >/tmp/waybar.log 2>&1 &
  nohup mako >/tmp/mako.log 2>&1 &
fi
hyprctl reload >/dev/null 2>&1 || true
