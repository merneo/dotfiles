#!/bin/bash

# =============================================================================
# HYPRLAND CORNER MODE SCRIPT
# Author: merneo
# Purpose: Switches the desktop aesthetic to sharp, square corners (0px radius)
#          and disables animations for a snappy, instant response feel.
# =============================================================================

set -e

# AUTO-DETECT HYPRLAND INSTANCE
# Ensures hyprctl commands target the correct active session.
if [ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    export HYPRLAND_INSTANCE_SIGNATURE=$(ls -t /run/user/$(id -u)/hypr/ | head -1)
fi

# CONFIG PATHS
HYPR_CONF=$(readlink -f ~/.config/hypr/hyprland.conf)
ALBERT_CONFIG="$HOME/.config/albert/config"
MAKO_CONF="$HOME/.config/mako/config"

# 1. APPLY HYPRLAND CHANGES
# Immediate Runtime Changes:
# - Set rounding to 0px (Sharp)
hyprctl keyword decoration:rounding 0 > /dev/null
# - Disable animations for instant window transitions
hyprctl keyword animations:enabled 0 > /dev/null

# Persistent Config Changes (sed):
# - Update 'rounding' parameter in hyprland.conf
sed -i 's/rounding = .*/rounding = 0/' "$HYPR_CONF"
# - Disable 'animations' block in hyprland.conf
sed -i '/^animations {/,/^}/ s/enabled = .*/enabled = no/' "$HYPR_CONF"

# 2. APPLY ALBERT LAUNCHER CHANGES
if [ -f "$ALBERT_CONFIG" ]; then
    # Switch to the standard (sharp) Catppuccin theme
    sed -i 's/^theme=.*/theme=Catppuccin Mocha/' "$ALBERT_CONFIG"
    sed -i 's/^darkTheme=.*/darkTheme=Catppuccin Mocha/' "$ALBERT_CONFIG"
    sed -i 's/^lightTheme=.*/lightTheme=Catppuccin Mocha/' "$ALBERT_CONFIG"
fi

# 3. APPLY MAKO NOTIFICATION CHANGES
if [ -f "$MAKO_CONF" ]; then
    # Update border radius for notifications to 0
    sed -i 's/border-radius=.*/border-radius=0/' "$MAKO_CONF"
    # Reload mako to apply changes immediately
    pkill -u "$(id -u)" mako
    sleep 0.5
    mako &
fi

# 4. RESTART ALBERT LAUNCHER
# Restarting is required for Albert to pick up the theme change from the config file.
pkill -f "albert" 2>/dev/null || true
sleep 0.5
albert &

notify-send "Mode: Corner" "Sharp corners enabled (0px) | Animations OFF"
