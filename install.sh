#!/bin/bash

# =============================================================================
# DOTFILES INSTALLER
# Author: merneo
# Purpose: Installs configurations and prompts for Waybar style selection.
# =============================================================================

set -e

DOTFILES_DIR="$HOME/dotfiles"

echo "Starting Dotfiles Installation..."

# 1. Waybar Selection
echo ""
echo "--------------------------------------------------"
echo "Select Waybar Style:"
echo "1) V1 (Original - Top Bar, minimal)"
echo "2) V2 (New - Top Bar, modular, weather, extra info)"
echo "--------------------------------------------------"
read -p "Enter choice [1-2] (default: 2): " wb_choice

# Default to 2 if empty
if [[ -z "$wb_choice" ]]; then
    wb_choice=2
fi

if [[ "$wb_choice" == "1" ]]; then
    echo "-> Selected Waybar V1"
    cp "$DOTFILES_DIR/waybar/themes/v1/config.jsonc" "$DOTFILES_DIR/waybar/.config/waybar/config.jsonc"
    cp "$DOTFILES_DIR/waybar/themes/v1/style.css" "$DOTFILES_DIR/waybar/.config/waybar/style.css"
else
    echo "-> Selected Waybar V2"
    cp "$DOTFILES_DIR/waybar/themes/v2/config.jsonc" "$DOTFILES_DIR/waybar/.config/waybar/config.jsonc"
    cp "$DOTFILES_DIR/waybar/themes/v2/style.css" "$DOTFILES_DIR/waybar/.config/waybar/style.css"
fi

# 2. Symlink/Copy Configurations
echo ""
echo "Installing configurations..."

# Ensure directories exist
mkdir -p ~/.config/hypr
mkdir -p ~/.config/waybar
mkdir -p ~/.config/kitty
mkdir -p ~/.config/nvim
mkdir -p ~/.local/share/albert
mkdir -p ~/.config/swayosd
mkdir -p ~/.local/bin

# Copy files (Safe copy - backup logic could be added here)
cp -r "$DOTFILES_DIR/hypr/.config/hypr" ~/.config/
cp -r "$DOTFILES_DIR/waybar/.config/waybar" ~/.config/
cp -r "$DOTFILES_DIR/kitty/.config/kitty" ~/.config/
cp -r "$DOTFILES_DIR/nvim/.config/nvim" ~/.config/
cp -r "$DOTFILES_DIR/albert/.local/share/albert" ~/.local/share/
cp -r "$DOTFILES_DIR/swayosd/.config/swayosd" ~/.config/
cp "$DOTFILES_DIR/tmux/.tmux.conf" ~/
cp -r "$DOTFILES_DIR/scripts/.local/bin" ~/.local/

# Make scripts executable
chmod +x ~/.local/bin/*.sh
chmod +x ~/.config/waybar/weather.sh

echo ""
echo "Installation Complete!"
echo "Please restart Hyprland to apply all changes."
