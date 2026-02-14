#!/usr/bin/env sh
set -eu

dir="$HOME/Pictures/Screenshots"
mkdir -p "$dir"

file="$dir/$(date +%Y-%m-%d_%H-%M-%S).png"
grim "$file"
