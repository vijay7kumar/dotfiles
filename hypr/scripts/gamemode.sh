#!/usr/bin/env bash
#                                      __   
#   ___ ____ ___ _  ___ __ _  ___  ___/ /__ 
#  / _ `/ _ `/  ' \/ -_)  ' \/ _ \/ _  / -_)
#  \_, /\_,_/_/_/_/\__/_/_/_/\___/\_,_/\__/ 
# /___/                                     
# 


jay_cache_folder="$HOME/.cache/jay/hyprland-dotfiles"

# Notifications
source "$HOME/.config/jay/scripts/jay-notification-handler"
APP_NAME="System"
NOTIFICATION_ICON="joystick"

if [ -f $HOME/.config/jay/settings/gamemode-enabled ]; then
  if [ -f $jay_cache_folder/restart-wpauto ]; then
    rm $jay_cache_folder/restart-wpauto
    $HOME/.config/jay/scripts/jay-wallpaper-automation &
  fi
  hyprctl reload
  rm $HOME/.config/jay/settings/gamemode-enabled
  notify_user --a "${APP_NAME}" \
            --i "${NOTIFICATION_ICON}" \
            --s "Gamemode deactivated" \
            --m "Animations and blur are now enabled."
else
  if [ -f $jay_cache_folder/wallpaper-automation ]; then
    touch $jay_cache_folder/restart-wpauto
    $HOME/.config/jay/scripts/jay-wallpaper-automation
  fi
  hyprctl eval "activate_gamemode()"
  touch $HOME/.config/jay/settings/gamemode-enabled
  notify_user --a "${APP_NAME}" \
          --i "${NOTIFICATION_ICON}" \
          --s "Gamemode activated" \
          --m "Animations and blur are now disabled."
fi