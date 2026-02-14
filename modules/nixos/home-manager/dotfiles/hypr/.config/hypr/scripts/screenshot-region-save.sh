#!/usr/bin/env sh
set -eu

dir="$HOME/Pictures/Screenshots"
mkdir -p "$dir"

region="$(slurp)"
file="$dir/$(date +%Y-%m-%d_%H-%M-%S).png"
grim -g "$region" "$file"
