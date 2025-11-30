#!/bin/bash

# =============================================================================
# SCREENSHOT MODE SCRIPT
# Author: merneo
# Purpose: Prepares the desktop for clean screenshots by setting static data.
# Logic:
# 1. Backs up current configs.
# 2. Replaces dynamic elements (time) with static strings ("00:00 AM").
# 3. Reloads UI components (Waybar, Tmux) to apply changes.
# =============================================================================

# BACKUP
# Prevents data loss by saving the original configuration states.
cp ~/.config/waybar/config.jsonc ~/.config/waybar/config.jsonc.bak 2>/dev/null
cp ~/.tmux.conf ~/.tmux.conf.bak 2>/dev/null

# STATIC TIME OVERRIDE
# Uses sed to modify the config files in-place.
# Goal: Ensure screenshots look consistent regardless of when they are taken.

# Waybar: Replace clock format
sed -i 's/"format": "{:%I:%M %p}"/"format": "00:00 AM"/' ~/.config/waybar/config.jsonc

# Tmux: Replace status bar time
sed -i "s/status-right '#\[fg=#a6e3a1\] #(date.*/status-right '#[fg=#a6e3a1] 00:00 AM '/" ~/.tmux.conf

# SERVICE RESTART
# Reloads the affected applications to render the static changes.

# Waybar
pkill waybar
sleep 0.5
waybar &

# Kitty (Terminal)
# Sending SIGUSR1 forces a config reload in running Kitty instances.
killall -SIGUSR1 kitty 2>/dev/null

# Tmux
# Source the modified config and refresh the client.
tmux source-file ~/.tmux.conf 2>/dev/null
tmux refresh-client 2>/dev/null

echo "✓ Screenshot mode activated - time set to 00:00 AM"