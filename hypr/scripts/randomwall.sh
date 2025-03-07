#!/usr/bin/env bash

# Set interval in minutes (default: 10 minutes)
INTERVAL=${1:-15}

# Set the wallpaper directory
WALLPAPER_DIR="$(xdg-user-dir PICTURES)/humongousdude.github.io/wallpapers/"
[ -d "$WALLPAPER_DIR" ] || WALLPAPER_DIR="$(xdg-user-dir PICTURES)"

# Function to switch wallpaper
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

    eww kill
    eww open bar
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
