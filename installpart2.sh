#!/usr/bin/env bash

rm ~/.config/gtk-4.0/gtk.css
sudo cp /usr/share/themes/adw-gtk3-dark/gtk-4.0/gtk.css ~/.config/gtk-4.0/
chown whoami ~/.config/gtk-4.0/gtk.css
