#!/usr/bin/env bash
# Volume / brightness keys. Changes are made with wpctl / brightnessctl (always works);
# swayosd is only used to DRAW the popup, so a missing PulseAudio layer can't break the keys.
# Usage: osd.sh vol-up|vol-down|vol-mute|mic-mute|bright-up|bright-down

show() {  # show <icon> <0.0-1.0> <text>
    command -v swayosd-client >/dev/null && pgrep -x swayosd-server >/dev/null || return 0
    swayosd-client --custom-icon "$1" --custom-progress "$2" --custom-progress-text "$3" 2>/dev/null
}

show_volume() {
    local out vol pct icon
    out=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)          # "Volume: 0.65 [MUTED]"
    vol=$(awk '{print $2}' <<< "$out"); pct=$(awk -v v="$vol" 'BEGIN{printf "%d", v*100+0.5}')
    if [[ $out == *MUTED* ]]; then show audio-volume-muted-symbolic 0 "Muted"; return; fi
    if   (( pct >= 66 )); then icon=audio-volume-high-symbolic
    elif (( pct >= 33 )); then icon=audio-volume-medium-symbolic
    else                       icon=audio-volume-low-symbolic; fi
    show "$icon" "$vol" "${pct}%"
}

show_brightness() {
    local cur max
    cur=$(brightnessctl get); max=$(brightnessctl max)
    show display-brightness-symbolic "$(awk -v c="$cur" -v m="$max" 'BEGIN{printf "%.2f", c/m}')" "$(( cur * 100 / max ))%"
}

case $1 in
    vol-up)      wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+; show_volume ;;
    vol-down)    wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-; show_volume ;;
    vol-mute)    wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle; show_volume ;;
    mic-mute)    wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
                 if [[ $(wpctl get-volume @DEFAULT_AUDIO_SOURCE@) == *MUTED* ]]; then show microphone-sensitivity-muted-symbolic 0 "Mic off"
                 else show microphone-sensitivity-high-symbolic 1 "Mic on"; fi ;;
    bright-up)   brightnessctl -e4 -n2 set 5%+ >/dev/null; show_brightness ;;
    bright-down) brightnessctl -e4 -n2 set 5%- >/dev/null; show_brightness ;;
esac
