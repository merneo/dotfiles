#!/bin/bash

# =============================================================================
# EFFECTS TOGGLE SCRIPT
# Author: merneo
# Purpose: Toggles desktop visual effects (blur, shadows, transparency) on/off.
# Usage: Bound to Super+Shift+E in Hyprland.
# =============================================================================

set -e
set -x # Enable shell debugging - IMPORTANT FOR TROUBLESHOOTING

notify-send "DEBUG: Effects Toggle script started." # Early notification for debugging

# LOGIC
# Checks the current state of 'blur' in the Hyprland config.
# If 'enabled = true' is found, it assumes effects are ON and triggers the OFF script.
# Otherwise, it triggers the ON script.

HYPR_CONF=$(readlink -f ~/.config/hypr/hyprland.conf)

if grep -A 3 "blur {" "$HYPR_CONF" | grep -qE "enabled = (true|yes)"; then
  # State: Effects are currently ENABLED -> Switch to DISABLED
  notify-send "Toggling Effects" "Switching to Effects OFF..."
  ~/.local/bin/effects-off.sh
else
  # State: Effects are currently DISABLED -> Switch to ENABLED
  notify-send "Toggling Effects" "Switching to Effects ON..."
  ~/.local/bin/effects-on.sh
fi