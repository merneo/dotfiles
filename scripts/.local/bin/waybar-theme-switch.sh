#!/bin/bash

# =============================================================================
# WAYBAR THEME SWITCHER
# Author: merneo
# Purpose: Allows the user to switch between Waybar themes (v1 - Original, v2 - New).
# =============================================================================

set -e

THEME_DIR="$HOME/dotfiles/waybar/themes"
CONFIG_DIR="$HOME/dotfiles/waybar/.config/waybar"

# Ensure directories exist
if [ ! -d "$THEME_DIR" ]; then
    echo "Error: Theme directory $THEME_DIR not found."
    exit 1
fi

echo "Select Waybar Style:"
echo "1) V1 (Original - Top Bar, minimal)"
echo "2) V2 (New - Top Bar, modular, weather, extra info)"
echo ""
read -p "Enter choice [1-2]: " choice

case $choice in
    1)
        echo "Switching to V1 (Original)..."
        cp "$THEME_DIR/v1/config.jsonc" "$CONFIG_DIR/config.jsonc"
        cp "$THEME_DIR/v1/style.css" "$CONFIG_DIR/style.css"
        ;;
    2)
        echo "Switching to V2 (New)..."
        cp "$THEME_DIR/v2/config.jsonc" "$CONFIG_DIR/config.jsonc"
        cp "$THEME_DIR/v2/style.css" "$CONFIG_DIR/style.css"
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

echo "Restarting Waybar..."
pkill waybar || true
sleep 0.5
# Attempt to start waybar if Hyprland is running
if pgrep -x "Hyprland" > /dev/null; then
    waybar > /dev/null 2>&1 &
    echo "Waybar restarted."
else
    echo "Hyprland not running. Waybar config updated but not started."
fi
