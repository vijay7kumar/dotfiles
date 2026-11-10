#!/usr/bin/env bash
# One-time: let spicetify patch Spotify and apply the wallpaper-matched Matugen theme.
# Run after: yay -S spotify spicetify-cli   — and open Spotify once, log in, close it.
set -e
SPOTIFY=/opt/spotify
[[ -d $SPOTIFY ]] || { echo "Spotify not found in /opt/spotify (install with: yay -S spotify)"; exit 1; }
sudo chmod a+wr "$SPOTIFY" && sudo chmod a+wr -R "$SPOTIFY/Apps"
spicetify >/dev/null 2>&1 || true                       # creates config-xpui.ini
spicetify config current_theme Matugen color_scheme Base inject_css 1 replace_colors 1 overwrite_assets 1
spicetify backup apply
echo "Done — Spotify now follows your wallpaper colours."
