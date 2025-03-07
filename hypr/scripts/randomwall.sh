#!/usr/bin/env bash

# Set interval in minutes (default: 10 minutes)
INTERVAL=${1:-15}

# Set the wallpaper directory
WALLPAPER_DIR="$(xdg-user-dir PICTURES)/humongousdude.github.io/wallpapers/"
[ -d "$WALLPAPER_DIR" ] || WALLPAPER_DIR="$(xdg-user-dir PICTURES)"

# Function to switch wallpaper (rest of the script remains largely the same)

switch() {
    imgpath=$1
    read scale screenx screeny screensizey < <(hyprctl monitors -j | jq '.[] | select(.focused) | .scale, .x, .y, .height' | xargs)
    cursorposx=$(hyprctl cursorpos -j | jq '.x' 2>/dev/null) || cursorposx=960
    cursorposx=$(bc <<< "scale=0; ($cursorposx - $screenx) * $scale / 1")
    cursorposy=$(hyprctl cursorpos -j | jq '.y' 2>/dev/null) || cursorposy=540
    cursorposy=$(bc <<< "scale=0; ($cursorposy - $screeny) * $scale / 1")
    cursorposy_inverted=$((screensizey - cursorposy))

    [ -z "$imgpath" ] && echo "No image found, aborting." && exit 1

    # Apply wallpaper with smooth transition
    swww img "$imgpath" --transition-step 100 --transition-fps 120 \
        --transition-type grow --transition-angle 30 --transition-duration 1 \
        --transition-pos "$cursorposx, $cursorposy_inverted"

    # Update pywal and EWW
    wal -i "$imgpath"
    pywalfox update

    if update_gtk_theme; then # Call update_gtk_theme and check for success
        echo "GTK Colors updated successfully."
    else
        echo "Warning: GTK Color update failed. Check errors above."
    fi

    eww kill
    eww open bar
}

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
    sleep "${INTERVAL}m"
done
