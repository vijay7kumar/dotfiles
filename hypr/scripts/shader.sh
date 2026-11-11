#!/usr/bin/env bash
# Screen shaders. Usage: shader.sh [next|off|vibrance|warm|mono|retro]
# (hyprshade doesn't work with a Lua Hyprland config, so this talks to Hyprland directly.)
DIR="$HOME/.config/hypr/shaders"
STATE="$HOME/.cache/jay/current-shader"
ORDER=(off vibrance warm mono retro)
mkdir -p "$(dirname "$STATE")"
cur=$(cat "$STATE" 2>/dev/null || echo off)

want=${1:-next}
if [[ $want == next ]]; then
    for i in "${!ORDER[@]}"; do [[ ${ORDER[$i]} == "$cur" ]] && want=${ORDER[$(( (i + 1) % ${#ORDER[@]} ))]}; done
    [[ $want == next ]] && want=off
fi

if [[ $want == off ]]; then
    hyprctl eval 'hl.config({ decoration = { screen_shader = "" } })' >/dev/null
elif [[ -f $DIR/$want.frag ]]; then
    hyprctl eval "hl.config({ decoration = { screen_shader = \"$DIR/$want.frag\" } })" >/dev/null
else
    echo "unknown shader: $want (have: ${ORDER[*]})" >&2; exit 1
fi
echo "$want" > "$STATE"

source "$HOME/.config/jay/scripts/jay-notification-handler" 2>/dev/null &&
    notify_user --a "Screen shader" --i "preferences-desktop-display" --s "Shader: $want" --m "SUPER+ALT+V for the next one"
