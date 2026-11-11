#!/usr/bin/env bash
# Take README screenshots: opens a tidy layout on an empty workspace, captures it,
# closes everything and returns you to where you were (~20 seconds).
# Usage: ~/Projects/dotfiles/scripts/showcase.sh
set -u
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$REPO/screenshots"; mkdir -p "$OUT"
CLASS=com.rice.showcase

for c in grim ghostty btop cava jq tty-clock; do command -v "$c" >/dev/null || { echo "missing: $c"; exit 1; }; done

# first workspace from 6-10 with no windows on it
WS=$(hyprctl workspaces -j | jq -r '[.[] | select(.windows > 0) | .id] as $busy | [6,7,8,9,10] - $busy | first // 10')
back=$(hyprctl activeworkspace -j | jq -r '.id')

focus() { hyprctl dispatch "hl.dsp.focus({workspace = $1})" >/dev/null; }
# Launch through Hyprland with an explicit workspace: windows otherwise open on the
# workspace this script was started from (misc.initial_workspace_tracking).
term() {
    hyprctl dispatch "hl.dsp.exec_cmd(\"ghostty --class=$CLASS --gtk-single-instance=false $*\", { workspace = \"$WS silent\" })" >/dev/null
}
count() { hyprctl clients -j | jq "[.[] | select(.class == \"$CLASS\" and .workspace.id == $WS)] | length"; }
wait_for() { local n=$1 i; for i in $(seq 30); do [[ $(count) -ge $n ]] && return 0; sleep 0.2; done; return 1; }
close_all() {
    hyprctl clients -j | jq -r ".[] | select(.class == \"$CLASS\") | .address" |
        while read -r a; do hyprctl dispatch "hl.dsp.window.close({window = 'address:$a'})" >/dev/null; done
}
on_ws() { [[ $(hyprctl activeworkspace -j | jq -r '.id') == "$WS" ]]; }
shot()  { on_ws || { echo "not on workspace $WS — skipping $1 (nothing private is captured)"; return 1; }
          grim "$OUT/$1" && echo "saved $1"; }
trap 'close_all; pkill -x rofi 2>/dev/null; swaync-client -cp >/dev/null 2>&1; focus "$back"' EXIT

focus "$WS"; sleep 0.5

# 1. Desktop: system monitor (left half) + fastfetch + visualizer + clock (right side)
term -e btop;                 wait_for 1; sleep 0.4
term;                         wait_for 2; sleep 0.4      # plain shell shows fastfetch on start
term -e cava;                 wait_for 3; sleep 0.4
term -e tty-clock -c -s -C 4; wait_for 4
focus "$WS"; sleep 3
shot desktop.png
close_all; sleep 1

# 2. Clean wallpaper + bar
shot clean.png

# 3. Launcher
"$HOME/.config/hypr/scripts/launcher.sh" >/dev/null 2>&1 &
sleep 1.5; shot launcher.png
pkill -x rofi; sleep 0.5

# 4. Notification centre
swaync-client -op >/dev/null 2>&1; sleep 1.2
shot notifications.png
swaync-client -cp >/dev/null 2>&1

echo "Done — screenshots are in $OUT"
