#!/usr/bin/env bash
#                                      __   
#   ___ ____ ___ _  ___ __ _  ___  ___/ /__ 
#  / _ `/ _ `/  ' \/ -_)  ' \/ _ \/ _  / -_)
#  \_, /\_,_/_/_/_/\__/_/_/_/\___/\_,_/\__/ 
# /___/                                     
# 

# Notifications
source "$HOME/.config/jay/scripts/jay-notification-handler"

_loadGameMode() {
    hyprctl eval "activate_gamemode()"
}

if [ -f $HOME/.config/jay/settings/gamemode-enabled ]; then
    _loadGameMode
    notify_user --a "System" \
        --i "joystick" \
        --s "Gamemode activated" \
        --m "Animations and blur are now disabled."
fi