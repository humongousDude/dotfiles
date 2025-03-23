#!/usr/bin/env bash

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
CONFIG_DIR="$XDG_CONFIG_HOME/hypr"  # Custom config directory
CACHE_DIR="$XDG_CACHE_HOME/wallpaper-theming"    # Custom cache directory
STATE_DIR="$XDG_STATE_HOME/wallpaper-theming"    # Custom state directory

# Set interval in minutes (default: 10 minutes)
INTERVAL=${1:-15}

# Set the wallpaper directory
WALLPAPER_DIR="$(xdg-user-dir PICTURES)/humongousdude.github.io/wallpapers/"
[ -d "$WALLPAPER_DIR" ] || WALLPAPER_DIR="$(xdg-user-dir PICTURES)"

# Function to switch wallpaper
switch() {
    imgpath=$1

    [ -z "$imgpath" ] && echo "No image found, aborting." && exit 1

    swww img "$imgpath" --transition-step 100 --transition-fps 120 \
        --transition-type grow --transition-angle 30 --transition-duration 1 \
        --transition-pos "960, 540"

    wal -i "$imgpath"
    pywalfox update

    if "$CONFIG_DIR"/scripts/color_generation/applycolor.sh "$imgpath"; then # Pass wallpaper path to update_gtk_theme
        echo "GTK Theme colors updated successfully using AGS scripts and Gradience."
    else
        echo "Warning: GTK Theme color update failed (AGS/Gradience method). Check errors above."
    fi

    eww reload

    echo -e "Wallpaper changed to ${imgpath} at ${DATE}" >> "$CONFIG_DIR"/scripts/wall_log.txt
}

# Initialize EWW timer variable to "N/A" at script start
eww update wallpaper_timer_text="N/A"

# Infinite loop to change wallpaper every X minutes
while true; do
    # Pick a random wallpaper
    WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.jpeg' -o -iname '*.gif' \) | shuf -n 1)

    if [ -n "$WALLPAPER" ]; then
        switch "$WALLPAPER"
    else
        echo "No wallpapers found in $WALLPAPER_DIR"
        exit 1
    fi

    # Wait for the specified interval before changing again
    for (( i = INTERVAL * 60; i >= 0; i-- )); do # Loop in seconds for countdown
        minutes=$((i / 60))
        seconds=$((i % 60))
        timer_text=$(printf "%02d:%02d" "$minutes" "$seconds")
        eww update wallpaper_timer_text="$timer_text"
        sleep 1 # Wait for 1 second
    done

done
