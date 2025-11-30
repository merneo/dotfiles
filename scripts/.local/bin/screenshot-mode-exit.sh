#!/bin/bash

# =============================================================================
# SCREENSHOT MODE EXIT SCRIPT
# Author: merneo
# Purpose: Restores dynamic time and system configurations after taking screenshots.
# =============================================================================

set -e

WAYBAR_CONFIG="$HOME/.config/waybar/config.jsonc"
TMUX_CONFIG="$HOME/.tmux.conf"

# 1. RESTORE WAYBAR CONFIG
if [ -f "${WAYBAR_CONFIG}.bak" ]; then
    cp "${WAYBAR_CONFIG}.bak" "$WAYBAR_CONFIG"
    rm "${WAYBAR_CONFIG}.bak"
else
    # Fallback: sed replacement if backup is missing
    sed -i 's/"format": "00:00 AM"/"format": "{:%I:%M %p}"/' "$WAYBAR_CONFIG"
fi

# 2. RESTORE TMUX CONFIG
if [ -f "${TMUX_CONFIG}.bak" ]; then
    cp "${TMUX_CONFIG}.bak" "$TMUX_CONFIG"
    rm "${TMUX_CONFIG}.bak"
else
    # Fallback: sed replacement
    sed -i "s/status-right '#[fg=#a6e3a1] 00:00 AM '/status-right '#[fg=#a6e3a1] #(date +\"%I:%M %p\") '/" "$TMUX_CONFIG"
fi

# 3. RESTART SERVICES

# Restart Waybar
pkill waybar || true
sleep 0.5
waybar > /dev/null 2>&1 &

# Reload Kitty (force config reload)
killall -SIGUSR1 kitty 2>/dev/null || true

# Reload Tmux
if pgrep tmux > /dev/null; then
    tmux source-file "$TMUX_CONFIG" > /dev/null 2>&1
    tmux refresh-client > /dev/null 2>&1
fi

notify-send "✓ Screenshot Mode OFF" "Dynamic time and configs restored."