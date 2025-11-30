#!/bin/bash

# =============================================================================
# EFFECTS OFF SCRIPT
# Author: merneo
# Purpose: Disables desktop visual effects for a clean, opaque, high-performance look.
# =============================================================================

set -e
set -x # Enable shell debugging

# PATHS
HYPR_CONF=$(readlink -f ~/.config/hypr/hyprland.conf)
WAYBAR_CSS=$(readlink -f ~/.config/waybar/style.css)
KITTY_CONF=$(readlink -f ~/.config/kitty/kitty.conf)
EFFECTS_LOG="/tmp/effects_toggle.log" # Central log file for all effects scripts

# Function to send notifications, with fallback to echo to log/stderr
send_notification() {
    local title="$1"
    local message="$2"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [NOTIFY] $title: $message" >> "$EFFECTS_LOG"
    if command -v notify-send &> /dev/null; then
        notify-send "$title" "$message"
    else
        echo "[NOTIFICATION] $title: $message" >&2
    fi
}

echo "--- Effects OFF script started ---" >> "$EFFECTS_LOG"

# 1. UPDATE HYPRLAND CONFIG (Persistent)
# Disable blur and shadows
send_notification "Hyprland" "Disabling blur and shadows in config."
sed -i '/blur {/,/^    }/ s/enabled = \(true\|yes\)/enabled = no/' "$HYPR_CONF"
sed -i '/shadow {/,/^    }/ s/enabled = \(true\|yes\)/enabled = no/' "$HYPR_CONF"

# 2. UPDATE KITTY (Direct Config Modification + Remote Control)
send_notification "Kitty" "Setting opacity to 1.0 in kitty.conf."
sed -i 's/^background_opacity [0-9.]*/background_opacity 1.0/' "$KITTY_CONF"
# Apply opacity change to all running Kitty instances using remote control
# Find all Kitty PIDs and update each instance
for pid in $(pgrep -x kitty); do
    kitty @ --to "unix:@mykitty-${pid}" set-background-opacity 1.0 2>/dev/null || true
done

# 3. UPDATE WAYBAR CSS (Persistent)
# Set background to 100% opacity (1.0)
send_notification "Waybar" "Setting opacity to 1.0 in Waybar CSS."
sed -i 's/rgba(30, 30, 46, [0-9.]*)/rgba(30, 30, 46, 1.0)/' "$WAYBAR_CSS"

# 4. APPLY CHANGES

# Waybar: Restart to apply CSS (do this FIRST before hyprctl reload)
send_notification "Waybar" "Restarting Waybar."
pkill waybar || true
sleep 0.3
# Auto-detect current Hyprland instance signature
HYPR_SIGNATURE=$(ls -t /run/user/$(id -u)/hypr/ 2>/dev/null | grep "^[a-f0-9]" | head -1)
if [ -n "$HYPR_SIGNATURE" ]; then
    HYPRLAND_INSTANCE_SIGNATURE="$HYPR_SIGNATURE" waybar > /dev/null 2>&1 &
else
    waybar > /dev/null 2>&1 &
fi

# Hyprland: Reload config to apply blur/shadows
send_notification "Hyprland" "Reloading Hyprland config."
hyprctl reload > /dev/null 2>&1 || true

send_notification "✓ Effects DISABLED" "Blur: Off | Opacity: Opaque"
echo "--- Effects OFF script finished ---" >> "$EFFECTS_LOG"
