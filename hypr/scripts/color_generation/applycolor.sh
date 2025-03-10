#!/usr/bin/env bash

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
CONFIG_DIR="$XDG_CONFIG_HOME/hypr"  # Custom config directory
CACHE_DIR="$XDG_CACHE_HOME/wallpaper-theming"    # Custom cache directory
STATE_DIR="$XDG_STATE_HOME/wallpaper-theming"    # Custom state directory

update_gtk_theme() {
    # Ensure necessary directories exist
    mkdir -p "$CACHE_DIR"/user/generated
    mkdir -p "$STATE_DIR/scss"
    mkdir -p "$XDG_CONFIG_HOME/presets" # for gradience

    # Generate colors using colorgen.sh with pywal backend
    echo "IMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA $1"
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

        if ! /usr/bin/gradience-cli apply -p "$CACHE_DIR"/user/generated/gradience/preset.json --gtk both; then
            echo "Error: gradience-cli apply failed."
            return 1 # Indicate failure
        fi

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

update_dunst_theme() {
    # Apply Hyprland
    cp "$CONFIG_DIR/scripts/templates/dunst/dunstrc" "$XDG_CONFIG_HOME/dunst/"

  dunst_config_template="$CONFIG_DIR/scripts/templates/dunst/dunstrc" # Path to template dunst.conf
  dunst_config_target="$XDG_CONFIG_HOME/dunst/dunstrc"        # Path to user dunst.conf

  # Check if dunst.conf template exists
  if [ ! -f "$dunst_config_template" ]; then
    echo "Template file not found for Dunst. Skipping Dunst theming."
    return
  fi

  # Create dunst config directory if it doesn't exist
  mkdir -p "$XDG_CONFIG_HOME/dunst"

  # Copy template to user config directory
  cp "$dunst_config_template" "$dunst_config_target"

  for i in "${!colorlist[@]}"; do
      sed -i "s/{{ ${colorlist[$i]} }}/${colorvalues[$i]#\#}/g" "$XDG_CONFIG_HOME"/dunst/dunstrc
      done

  killall dunst
  dunst &

  echo "Dunst colors applied."
}


update_gtk_theme "$1"
update_hyprland_theme "$1" 
update_dunst_theme "$1" 
