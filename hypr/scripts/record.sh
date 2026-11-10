#!/usr/bin/env bash
# Toggle screen recording. Usage: record.sh [area|screen] [--audio]
# Saves to ~/Videos/Recordings, run again to stop.
source "$HOME/.config/jay/scripts/jay-notification-handler"
DIR="$HOME/Videos/Recordings"; mkdir -p "$DIR"

if pgrep -x wf-recorder >/dev/null; then
    pkill -INT -x wf-recorder
    sleep 0.3; pkill -RTMIN+8 waybar
    notify_user --a "Recorder" --i "media-record" --s "Recording saved" --m "$(ls -t "$DIR" | head -1)"
    exit 0
fi
command -v wf-recorder >/dev/null || { notify_user --a "Recorder" --s "wf-recorder not installed"; exit 1; }

FILE="$DIR/rec-$(date +%Y%m%d-%H%M%S).mp4"
ARGS=(-f "$FILE")
[[ $* == *--audio* ]] && ARGS+=(--audio)
if [[ ${1:-area} == area ]]; then
    notify_user --a "Recorder" --s "Select an area" --m "Drag to select · Esc to cancel"
    GEOM=$(slurp) || exit 0
    ARGS+=(-g "$GEOM")
else
    ARGS+=(-o "$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')")
fi
notify_user --a "Recorder" --i "media-record" --s "● Recording" --m "Stop: click ● REC in the bar, or SUPER+ALT+R"
wf-recorder "${ARGS[@]}" >/dev/null 2>&1 &
sleep 0.5; pkill -RTMIN+8 waybar
