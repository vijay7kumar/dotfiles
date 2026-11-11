#!/usr/bin/env bash
# Recolour Papirus folder icons to the closest match for the current wallpaper.
# Needs sudo (the icons live in /usr/share/icons). Usage: folder-color.sh [colour]
set -e
# Started with sudo? Re-run as the real user so the wallpaper colours are found.
if [[ $EUID -eq 0 && -n ${SUDO_USER:-} && $SUDO_USER != root ]]; then
    exec sudo -u "$SUDO_USER" -H "$(getent passwd "$SUDO_USER" | cut -d: -f6)/.config/hypr/scripts/folder-color.sh" "$@"
fi
pick() {
    local hex; hex=$(grep -oP '^\$source_color = rgba\(\K[0-9a-fA-F]{6}' "$HOME/.config/hypr/colors.conf")
    python3 - "$hex" <<'PY'
import sys, colorsys
h=sys.argv[1]; r,g,b=(int(h[i:i+2],16)/255 for i in (0,2,4))
hue,l,s=colorsys.rgb_to_hls(r,g,b); hue*=360
if s < 0.12: print("grey" if l > 0.25 else "black"); raise SystemExit
table=[(15,"red"),(35,"deeporange"),(50,"orange"),(70,"yellow"),(160,"green"),(185,"teal"),
       (200,"cyan"),(225,"blue"),(255,"indigo"),(285,"violet"),(320,"magenta"),(345,"pink"),(360,"red")]
print(next(n for lim,n in table if hue <= lim))
PY
}
COLOR=${1:-$(pick)}
echo "Folder colour: $COLOR"
sudo papirus-folders -C "$COLOR" --theme Papirus-Dark
