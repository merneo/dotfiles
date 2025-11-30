#!/bin/bash

# =============================================================================
# HYPRLAND ROUNDED MODE SCRIPT
# Author: merneo
# Purpose: Switches the desktop aesthetic to rounded corners (12px radius) and 
#          enables animations for a smooth, modern feel.
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
# - Set rounding to 12px (Rounded)
hyprctl keyword decoration:rounding 12 > /dev/null
# - Enable animations for fluid window movement
hyprctl keyword animations:enabled 1 > /dev/null

# Persistent Config Changes (sed):
# - Update 'rounding' parameter in hyprland.conf
sed -i 's/rounding = .*/rounding = 12/' "$HYPR_CONF"
# - Enable 'animations' block in hyprland.conf
sed -i '/^animations {/,/^}/ s/enabled = .*/enabled = yes/' "$HYPR_CONF"

# 2. APPLY ALBERT LAUNCHER CHANGES
if [ -f "$ALBERT_CONFIG" ]; then
    # Switch to the rounded variant of the Catppuccin theme
    sed -i 's/^theme=.*/theme=Catppuccin Mocha Rounded/' "$ALBERT_CONFIG"
    sed -i 's/^darkTheme=.*/darkTheme=Catppuccin Mocha Rounded/' "$ALBERT_CONFIG"
    sed -i 's/^lightTheme=.*/lightTheme=Catppuccin Mocha Rounded/' "$ALBERT_CONFIG"
fi

# 3. APPLY MAKO NOTIFICATION CHANGES
if [ -f "$MAKO_CONF" ]; then
    # Update border radius for notifications
    sed -i 's/border-radius=.*/border-radius=12/' "$MAKO_CONF"
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

notify-send "Mode: Rounded" "Rounded corners enabled (12px) | Animations ON"
