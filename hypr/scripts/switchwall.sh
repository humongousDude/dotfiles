#!/usr/bin/env bash

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

switch() {
	imgpath=$1
	read scale screenx screeny screensizey < <(hyprctl monitors -j | jq '.[] | select(.focused) | .scale, .x, .y, .height' | xargs)
	cursorposx=$(hyprctl cursorpos -j | jq '.x' 2>/dev/null) || cursorposx=960
	cursorposx=$(bc <<< "scale=0; ($cursorposx - $screenx) * $scale / 1")
	cursorposy=$(hyprctl cursorpos -j | jq '.y' 2>/dev/null) || cursorposy=540
	cursorposy=$(bc <<< "scale=0; ($cursorposy - $screeny) * $scale / 1")
	cursorposy_inverted=$((screensizey - cursorposy))

	if [ "$imgpath" == '' ]; then
		echo 'Aborted'
		exit 0
	fi

	swww img "$imgpath" --transition-step 100 --transition-fps 120 \
		--transition-type grow --transition-angle 30 --transition-duration 1 \
		--transition-pos "$cursorposx, $cursorposy_inverted"

    wal -i "$imgpath"
    pywalfox update

    eww kill
    eww open bar

    apply_gtk
}

if [ "$1" == "--noswitch" ]; then
	imgpath=$(swww query | awk -F 'image: ' '{print $2}')
elif [[ "$1" ]]; then
	switch "$1"
else
	# Select and set image (hyprland)

    cd "$(xdg-user-dir PICTURES)/Wallpapers" || cd "$(xdg-user-dir PICTURES)" || return 1
	switch "$(yad --width 1200 --height 800 --file --add-preview --large-preview --title='Choose wallpaper')"
fi

apply_gtk() { # Using gradience-cli
  usegradience=""
  if [[ "$usegradience" = "nogradience" ]]; then
    rm "$XDG_CONFIG_HOME/gtk-3.0/gtk.css"
    rm "$XDG_CONFIG_HOME/gtk-4.0/gtk.css"
    return
  fi

  # Copy template
  mkdir -p "$CACHE_DIR"/user/generated/gradience
  cp "scripts/templates/gradience/preset.json" "$CACHE_DIR"/user/generated/gradience/preset.json

  # Apply colors
  for i in "${!colorlist[@]}"; do
    sed -i "s/{{ ${colorlist[$i]} }}/${colorvalues[$i]}/g" "$CACHE_DIR"/user/generated/gradience/preset.json
  done

  mkdir -p "$XDG_CONFIG_HOME/presets" # create gradience presets folder
  # source $(eval echo $ILLOGICAL_IMPULSE_VIRTUAL_ENV)/bin/activate
  gradience-cli apply -p "$CACHE_DIR"/user/generated/gradience/preset.json --gtk both
  deactivate

  # And set GTK theme manually as Gradience defaults to light adw-gtk3
  # (which is unreadable when broken when you use dark mode)
  gsettings set org.gnome.desktop.interface gtk-theme adw-gtk3-dark
}
