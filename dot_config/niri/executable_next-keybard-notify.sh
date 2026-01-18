#!/usr/bin/env sh
set -eu

niri msg action switch-layout next >/dev/null

active_layout="$(niri msg -j keyboard-layouts | jq -r '.names[.current_idx] // "Unknown"')"
# {"names":["English (UK)","Danish"],"current_idx":0}

# Show a transient notification (requires a notification daemon)
notify-send -a "Keyboard Layout Switch" -t 750 "Active Layout: ${active_layout}"
