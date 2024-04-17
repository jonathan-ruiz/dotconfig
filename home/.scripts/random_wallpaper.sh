#!/bin/bash

# Directory containing wallpapers
WALLPAPER_DIR="$HOME/.config/i3/wallpapers"

# Select a random file from the directory
WALLPAPER=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)

# Set the wallpaper using feh
feh --bg-fill "$WALLPAPER"

