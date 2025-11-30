#!/bin/bash

# =============================================================================
# WALLPAPER CHANGE SCRIPT
# Author: merneo
# Purpose: Instantly changes the wallpaper on all monitors to a random one.
# Usage: Bound to Super+Shift+W or run manually.
# =============================================================================

# Exit on error
set -e

# CONFIGURATION
WALLPAPER_DIR="$HOME/Pictures/Wallpapers/walls"

# DEPENDENCY CHECK
if ! command -v swww &> /dev/null; then
    notify-send "Error" "swww is not installed."
    exit 1
fi

if ! command -v jq &> /dev/null; then
    notify-send "Error" "jq is not installed."
    exit 1
fi

# CHECK DIRECTORY
if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send "Wallpaper Error" "Directory not found: $WALLPAPER_DIR"
    exit 1
fi

# GET MONITORS
# Uses hyprctl to fetch JSON data and jq to extract monitor names.
monitors=($(hyprctl monitors -j 2>/dev/null | jq -r '.[].name' 2>/dev/null))

if [ ${#monitors[@]} -eq 0 ]; then
    notify-send "Wallpaper Error" "No monitors found"
    exit 1
fi

# FIND WALLPAPERS
# Recursively finds image files.
all_walls=($(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) 2>/dev/null | shuf))

if [ ${#all_walls[@]} -eq 0 ]; then
    notify-send "Wallpaper Error" "No wallpapers found in $WALLPAPER_DIR"
    exit 1
fi

# APPLY WALLPAPERS
# Loops through detected monitors and assigns a unique random wallpaper to each.
for i in "${!monitors[@]}"; do
    # Wrap index if we have more monitors than wallpapers
    wall_index=$((i % ${#all_walls[@]}))
    
    monitor="${monitors[$i]}"
    wallpaper="${all_walls[$wall_index]}"
    
    # Execute in background for speed
    swww img -o "$monitor" "$wallpaper" --transition-type fade --transition-duration 1 &
done

wait # Wait for all background processes to finish
notify-send "Wallpaper Changed" "New wallpaper applied successfully"