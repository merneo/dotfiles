#!/bin/bash

# =============================================================================
# WALLPAPER ROTATION SCRIPT
# Author: merneo
# Purpose: Rotates wallpapers across all connected monitors at a set interval.
# Dependencies: swww (Daemon + Client), jq (JSON parsing)
# =============================================================================

WALLPAPER_DIR="$HOME/Pictures/Wallpapers/walls"
LOG_FILE="/tmp/wallpaper-rotate.log"
MAX_RETRIES=3

# LOGGING
# Appends timestamped messages to a temporary log file for debugging.
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# DAEMON MANAGEMENT
# Ensures 'swww-daemon' is running before attempting to set wallpapers.
# Retries up to 3 times to handle race conditions during startup.
start_swww() {
    local retries=0
    while [ $retries -lt $MAX_RETRIES ]; do
        if pgrep -x swww-daemon > /dev/null; then
            log "swww-daemon is running"
            return 0
        fi

        log "Starting swww-daemon (attempt $((retries + 1))/$MAX_RETRIES)"
        swww-daemon &
        sleep 2  # Give daemon time to initialize socket

        if pgrep -x swww-daemon > /dev/null; then
            log "swww-daemon started successfully"
            return 0
        fi

        retries=$((retries + 1))
    done

    log "ERROR: Failed to start swww-daemon after $MAX_RETRIES attempts"
    return 1
}

# MAIN LOGIC
# 1. Detects active monitors.
# 2. Finds all wallpapers.
# 3. Shuffles wallpapers and assigns one to each monitor.
set_wallpapers() {
    # DETECT MONITORS
    # Uses hyprctl to get JSON data, parses with jq to extract names (e.g., eDP-1, HDMI-A-1).
    local monitors=($(hyprctl monitors -j 2>/dev/null | jq -r '.[].name' 2>/dev/null))

    if [ ${#monitors[@]} -eq 0 ]; then
        log "ERROR: No monitors found"
        return 1
    fi

    log "Found ${#monitors[@]} monitor(s): ${monitors[*]}"

    # VALIDATE DIRECTORY
    if [ ! -d "$WALLPAPER_DIR" ]; then
        log "ERROR: Wallpaper directory does not exist: $WALLPAPER_DIR"
        return 1
    fi

    # FETCH WALLPAPERS
    # Finds images recursively, handles spaces in names, and randomizes order.
    local all_walls=($(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) 2>/dev/null | shuf))

    if [ ${#all_walls[@]} -eq 0 ]; then
        log "ERROR: No wallpapers found in $WALLPAPER_DIR"
        return 1
    fi

    log "Found ${#all_walls[@]} wallpaper(s)"

    # APPLY WALLPAPERS
    # Iterates through monitors and assigns the next available unique wallpaper.
    local pids=()
    for i in "${!monitors[@]}"; do
        if [ $i -lt ${#all_walls[@]} ]; then
            local wallpaper="${all_walls[$i]}"
            log "Setting wallpaper for ${monitors[$i]}: $(basename "$wallpaper")"

            # Execute swww transition in background with timeout to prevent hanging
            # Timeout of 15 seconds should be more than enough for a 2-second fade
            (timeout 15 swww img -o "${monitors[$i]}" "$wallpaper" --transition-type fade --transition-duration 2 >> "$LOG_FILE" 2>&1) &
            pids+=($!)
        fi
    done

    # Wait for all background processes with a safety check
    local wait_count=0
    local max_wait=20  # Maximum 20 seconds total wait time
    while [ ${#pids[@]} -gt 0 ] && [ $wait_count -lt $max_wait ]; do
        for i in "${!pids[@]}"; do
            if ! kill -0 "${pids[$i]}" 2>/dev/null; then
                # Process finished, remove from array
                unset 'pids[$i]'
            fi
        done
        pids=("${pids[@]}")  # Re-index array

        if [ ${#pids[@]} -gt 0 ]; then
            sleep 1
            wait_count=$((wait_count + 1))
        fi
    done

    # Kill any remaining stuck processes
    if [ ${#pids[@]} -gt 0 ]; then
        log "WARNING: ${#pids[@]} wallpaper process(es) did not finish in time, killing them"
        for pid in "${pids[@]}"; do
            kill -9 "$pid" 2>/dev/null || true
        done
    fi

    log "Wallpapers set successfully"
    return 0
}

# CLEANUP
# Ensures clean exit when script is killed.
cleanup() {
    log "Wallpaper rotation script terminated"
    exit 0
}

trap cleanup SIGTERM SIGINT

# =============================================================================
# EXECUTION START
# =============================================================================

log "=== Wallpaper rotation script started ==="

# Initialize engine
if ! start_swww; then
    log "FATAL: Cannot start swww-daemon, exiting"
    exit 1
fi

# Initial set on startup
if ! set_wallpapers; then
    log "WARNING: Failed to set initial wallpapers, will retry in rotation loop"
fi

# INFINITE LOOP
# Rotates wallpapers every 3 minutes (180 seconds).
log "Starting wallpaper rotation loop (interval: 180 seconds)"
while true; do
    sleep 180
    log "--- Rotation cycle ---"
    set_wallpapers || log "WARNING: Wallpaper rotation failed, will retry next cycle"
done