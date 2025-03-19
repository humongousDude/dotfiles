#!/usr/bin/env bash

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
CONFIG_DIR="$XDG_CONFIG_HOME/hypr"  # Custom config directory
CACHE_DIR="$XDG_CACHE_HOME/wallpaper-theming"    # Custom cache directory
STATE_DIR="$XDG_STATE_HOME/wallpaper-theming"    # Custom state directory

switch() {
    imgpath=$1
    read scale screenx screeny screensizey < <(hyprctl monitors -j | jq '.[] | select(.focused) | .scale, .x, .y, .height' | xargs)
    cursorposx=$(hyprctl cursorpos -j | jq '.x' 2>/dev/null) || cursorposx=960
    cursorposx=$(bc <<< "scale=0; ($cursorposx - $screenx) * $scale / 1")
    cursorposy=$(hyprctl cursorpos -j | jq '.y' 2>/dev/null) || cursorposy=540
    cursorposy=$(bc <<< "scale=0; ($cursorposy - $screeny) * $scale / 1")
    cursorposy_inverted=$((screensizey - cursorposy))

    [ -z "$imgpath" ] && echo 'Aborted' && exit 0

    swww img "$imgpath" --transition-step 100 --transition-fps 120 \
        --transition-type grow --transition-angle 30 --transition-duration 1 \
        --transition-pos "$cursorposx, $cursorposy_inverted"

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

if [ "$1" == "--noswitch" ]; then
    imgpath=$(swww query | awk -F 'image: ' '{print $2}')
elif [[ "$1" ]]; then
    switch "$1"
else
    cd "$(xdg-user-dir PICTURES)/humongousdude.github.io/wallpapers/" || cd "$(xdg-user-dir PICTURES)" || exit 1
    switch "$(yad --width 1200 --height 800 --file --add-preview --large-preview --title='Choose a wallpaper')"
fi
