#!/usr/bin/env bash

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
CONFIG_DIR="$XDG_CONFIG_HOME/hypr"  # Custom config directory
CACHE_DIR="$XDG_CACHE_HOME/wallpaper-theming"    # Custom cache directory
STATE_DIR="$XDG_STATE_HOME/wallpaper-theming"    # Custom state directory

apply_themes() {
    update_gtk_theme "$imgpath"
    update_hyprland_theme "$imgpath"
}

update_gtk_theme() {
    # Ensure necessary directories exist
    mkdir -p "$CACHE_DIR"/user/generated
    mkdir -p "$STATE_DIR/scss"
    mkdir -p "$XDG_CONFIG_HOME/presets" # for gradience

    # Generate colors using colorgen.sh with pywal backend
    "$CONFIG_DIR"/scripts/color_generation/colorgen.sh "$1" --apply  # Pass wallpaper path and --apply

    if [ ! -f "$STATE_DIR/scss/_material.scss" ]; then
        echo "Error: _material.scss not generated. GTK Theme update failed."
        return 1
    fi

    # Extract color names and values from _material.scss (from applycolor.sh)
    colornames=$(cat "$STATE_DIR/scss/_material.scss" | cut -d: -f1)
    colorstrings=$(cat "$STATE_DIR/scss/_material.scss" | cut -d: -f2 | cut -d ' ' -f2 | cut -d ";" -f1)
    IFS=$'\n'
    colorlist=($colornames)     # Array of color names
    colorvalues=($colorstrings) # Array of color values


    # --- Apply GTK Function (from applycolor.sh, adapted) ---
    apply_gtk_internal() { # Renamed to avoid conflict if you still have original applycolor.sh sourced
        # Copy template
        mkdir -p "$CACHE_DIR"/user/generated/gradience
        cp "$CONFIG_DIR/scripts/templates/gradience/preset.json" "$CACHE_DIR"/user/generated/gradience/preset.json

        # Apply colors
        for i in "${!colorlist[@]}"; do
            sed -i "s/{{ ${colorlist[$i]} }}/${colorvalues[$i]}/g" "$CACHE_DIR"/user/generated/gradience/preset.json
        done

        # source ./venv/bin/activate
        if ! gradience-cli apply -p "$CACHE_DIR"/user/generated/gradience/preset.json --gtk both; then
            echo "Error: gradience-cli apply failed."
            deactivate
            return 1 # Indicate failure
        fi
        deactivate

        # And set GTK theme manually as Gradience defaults to light adw-gtk3
        gsettings set org.gnome.desktop.interface gtk-theme adw-gtk3-dark
    }
    # --- End of Apply GTK Function ---

    if apply_gtk_internal; then # Call the internal GTK apply function
        echo "GTK theme colors applied using Gradience."
        return 0 # Indicate success
    else
        echo "Error: GTK theme color application failed."
        return 1 # Indicate failure
    fi
}

update_hyprland_theme() {
    # Apply Hyprland
    cp "$CONFIG_DIR/scripts/templates/hypr/colors.conf" "$CONFIG_DIR/hyprland/"

    for i in "${!colorlist[@]}"; do
        sed -i "s/{{ ${colorlist[$i]} }}/${colorvalues[$i]#\#}/g" "$CONFIG_DIR"/hyprland/colors.conf
        done
}

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

    if apply_themes "$imgpath"; then # Pass wallpaper path to update_gtk_theme
        echo "GTK Theme colors updated successfully using AGS scripts and Gradience."
    else
        echo "Warning: GTK Theme color update failed (AGS/Gradience method). Check errors above."
    fi

    eww reload
}

if [ "$1" == "--noswitch" ]; then
    imgpath=$(swww query | awk -F 'image: ' '{print $2}')
elif [[ "$1" ]]; then
    switch "$1"
else
    cd "$(xdg-user-dir PICTURES)/humongousdude.github.io/wallpapers/" || cd "$(xdg-user-dir PICTURES)" || exit 1
    switch "$(yad --width 1200 --height 800 --file --add-preview --large-preview --title='Choose a wallpaper')"
fi
