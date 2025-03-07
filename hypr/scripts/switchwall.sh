#!/usr/bin/env bash

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

update_dunst_colors() {
    # Extract colors from colors.json
    COLOR0=$(grep "\"color0\"" "$HOME/.cache/wal/colors.json" | awk -F '"' '{print $4}')
    COLOR7=$(grep "\"color7\"" "$HOME/.cache/wal/colors.json" | awk -F '"' '{print $4}')
    COLOR8=$(grep "\"color8\"" "$HOME/.cache/wal/colors.json" | awk -F '"' '{print $4}')
    COLOR11=$(grep "\"color11\"" "$HOME/.cache/wal/colors.json" | awk -F '"' '{print $4}')
    COLOR15=$(grep "\"color15\"" "$HOME/.cache/wal/colors.json" | awk -F '"' '{print $4}')

    # Basic error checking (optional but recommended)
    if [ -z "$COLOR0" ] || [ -z "$COLOR7" ] || [ -z "$COLOR8" ] || [ -z "$COLOR11" ] || [ -z "$COLOR15" ]; then
        echo "Warning: Could not extract all Dunst colors from colors.json."
    fi

    # Update Dunst configuration file (~/.config/dunst/dunstrc)
    sed -i "s|^background = .*|background = \"${COLOR0}\"|" "$HOME/.config/dunst/dunstrc"
    sed -i "s|^foreground = .*|foreground = \"${COLOR7}\"|" "$HOME/.config/dunst/dunstrc"
    sed -i "s|^frame_color = .*|frame_color = \"${COLOR8}\"|" "$HOME/.config/dunst/dunstrc"
    sed -i "s|^highlight = .*|highlight = \"${COLOR11}\"|" "$HOME/.config/dunst/dunstrc"
    sed -i "s|^sep_color = .*|sep_color = \"${COLOR8}\"|" "$HOME/.config/dunst/dunstrc" # Example using frame color as separator
    sed -i "s|^indicator_color = .*|indicator_color = \"${COLOR15}\"|" "$HOME/.config/dunst/dunstrc"

    # Reload Dunst to apply changes (using pkill -USR1, check your Dunst version/config)
    killall dunst

    echo "Dunst colors updated to match wallpaper."
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

    # Generate colors and apply them to GTK & system
    wal -i "$imgpath"
    pywalfox update

    update_dunst_colors

    # Reload EWW bar
    eww kill
    eww open bar
}

if [ "$1" == "--noswitch" ]; then
    imgpath=$(swww query | awk -F 'image: ' '{print $2}')
elif [[ "$1" ]]; then
    switch "$1"
else
    cd "$(xdg-user-dir PICTURES)/humongousdude.github.io/wallpapers/" || cd "$(xdg-user-dir PICTURES)" || exit 1
    switch "$(yad --width 1200 --height 800 --file --add-preview --large-preview --title='Choose a wallpaper')"
fi
