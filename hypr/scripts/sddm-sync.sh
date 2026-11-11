#!/usr/bin/env bash
# Copy the current wallpaper + matugen colours into the SDDM "rice" login theme.
# No sudo needed: sddm-setup.sh made these two files writable by you.
THEME=/usr/share/sddm/themes/rice
[[ -w $THEME/Backgrounds/rice.jpg && -w $THEME/Themes/rice.conf ]] || exit 0
WALL=${1:-$(cat "$HOME/.cache/jay/hyprland-dotfiles/current_wallpaper" 2>/dev/null)}
[[ -f $WALL ]] && magick "$WALL" -delete 1--1 -resize '1920x1080^' -gravity center -extent 1920x1080 -quality 90 "$THEME/Backgrounds/rice.jpg" 2>/dev/null
[[ -f $HOME/.config/sddm-rice/rice.conf ]] && cat "$HOME/.config/sddm-rice/rice.conf" > "$THEME/Themes/rice.conf"
exit 0
