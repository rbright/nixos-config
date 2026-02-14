#!/usr/bin/env sh
set -eu

region="$(slurp)"
grim -g "$region" - | wl-copy
