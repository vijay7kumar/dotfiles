#!/usr/bin/env bash
# Volume / brightness with an on-screen popup (swayosd), falls back to plain wpctl/brightnessctl.
# Usage: osd.sh vol-up|vol-down|vol-mute|mic-mute|bright-up|bright-down
if command -v swayosd-client >/dev/null && pgrep -x swayosd-server >/dev/null; then
    case $1 in
        vol-up)      swayosd-client --output-volume raise --max-volume 100 ;;
        vol-down)    swayosd-client --output-volume lower ;;
        vol-mute)    swayosd-client --output-volume mute-toggle ;;
        mic-mute)    swayosd-client --input-volume mute-toggle ;;
        bright-up)   swayosd-client --brightness raise ;;
        bright-down) swayosd-client --brightness lower ;;
    esac
else
    case $1 in
        vol-up)      wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+ ;;
        vol-down)    wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- ;;
        vol-mute)    wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
        mic-mute)    wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle ;;
        bright-up)   brightnessctl -e4 -n2 set 5%+ ;;
        bright-down) brightnessctl -e4 -n2 set 5%- ;;
    esac
fi
