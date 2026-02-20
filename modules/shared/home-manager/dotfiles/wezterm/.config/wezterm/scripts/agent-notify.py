#!/usr/bin/env sh
# Compatibility shim: canonical notifier script now lives under ~/.agents/scripts.
exec "$HOME/.agents/scripts/agent-notify.py" "$@"
