#!/usr/bin/env bash
# Waybar indicator: shows "● REC mm:ss" while wf-recorder runs, hidden otherwise.
pid=$(pgrep -x wf-recorder | head -1)
if [[ -z $pid ]]; then echo '{"text":""}'; exit 0; fi
secs=$(ps -o etimes= -p "$pid" | tr -d ' ')
printf '{"text":"● REC %02d:%02d","class":"recording","tooltip":"Recording — click (or SUPER+ALT+R) to stop"}\n' $((secs/60)) $((secs%60))
