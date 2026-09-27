#!/usr/bin/env bash
#                    __
#  _    _____ ___ __/ /  ___ _____
# | |/|/ / _ `/ // / _ \/ _ `/ __/
# |__,__/\_,_/\_, /_.__/\_,_/_/
#            /___/
#

# -----------------------------------------------------
# Prevent duplicate launches: only the first parallel
# invocation proceeds; all others exit immediately.
# -----------------------------------------------------

exec 200>/tmp/waybar-launch.lock
flock -n 200 || exit 0

# -----------------------------------------------------
# Quit all running waybar instances
# -----------------------------------------------------

killall waybar || true
pkill waybar || true
sleep 0.5

# -----------------------------------------------------
# Default theme: /THEMEFOLDER;/VARIATION
# -----------------------------------------------------

default_theme="/jay-glass-center;/jay-glass-center/default"

# -----------------------------------------------------
# Remove incompatible themes
# -----------------------------------------------------

if [ -f ~/.config/jay/settings/waybar-theme.sh ]; then
    themestyle=$(cat ~/.config/jay/settings/waybar-theme.sh)
    case "$themestyle" in
    "/jay-modern;/jay-modern/light")
        echo "$default_theme" >~/.config/jay/settings/waybar-theme.sh
        ;;
    "/jay-modern;/jay-modern/dark")
        echo "$default_theme" >~/.config/jay/settings/waybar-theme.sh
        ;;
    "/jay;/jay/light")
        echo "$default_theme" >~/.config/jay/settings/waybar-theme.sh
        ;;
    "/jay;/jay/dark")
        echo "$default_theme" >~/.config/jay/settings/waybar-theme.sh
        ;;
    *)
        echo
        ;;
    esac
    if [ -d $HOME/.config/waybar/themes/jay-modern/light ]; then
        rm -rf $HOME/.config/waybar/themes/jay-modern/light
    fi
    if [ -d $HOME/.config/waybar/themes/jay-modern/dark ]; then
        rm -rf $HOME/.config/waybar/themes/jay-modern/dark
    fi
    if [ -d $HOME/.config/waybar/themes/jay/light ]; then
        rm -rf $HOME/.config/waybar/themes/jay/light
    fi
    if [ -d $HOME/.config/waybar/themes/jay/dark ]; then
        rm -rf $HOME/.config/waybar/themes/jay/dark
    fi
fi

# -----------------------------------------------------
# Get current theme information from ~/.config/jay/settings/waybar-theme.sh
# -----------------------------------------------------

if [ -f ~/.config/jay/settings/waybar-theme.sh ]; then
    themestyle=$(cat ~/.config/jay/settings/waybar-theme.sh)
else
    touch ~/.config/jay/settings/waybar-theme.sh
    echo "$default_theme" >~/.config/jay/settings/waybar-theme.sh
    themestyle=$default_theme
fi

IFS=';' read -ra arrThemes <<<"$themestyle"
echo ":: Theme: ${arrThemes[0]}"

if [ ! -f ~/.config/waybar/themes${arrThemes[1]}/style.css ]; then
    themestyle=$default_theme
fi

# -----------------------------------------------------
# Toggle Waybar modules
# -----------------------------------------------------

_toggle_module() {
    local module_name=$1
    local settings_file=$2
    local value=$(cat "$settings_file")
    local file="$HOME/.config/waybar/themes${arrThemes[0]}/config"
    if [ "$value" == "True" ]; then
        search_string=" \"$module_name\""
        if ! grep -qF "$search_string" "$file"; then
            sed -i "s| //\"$module_name\"| \"$module_name\"|g" "$file"
        fi    
    else
        search_string=" //\"$module_name\""
        if ! grep -qF "$search_string" "$file"; then
            sed -i "s| \"$module_name\"| //\"$module_name\"|g" "$file"
        fi    
    fi
}

_toggle_module "custom/appmenu" "$HOME/.config/jay/settings/waybar_appmenu.sh"
_toggle_module "wlr/taskbar" "$HOME/.config/jay/settings/waybar_taskbar.sh"
_toggle_module "group/quicklinks" "$HOME/.config/jay/settings/waybar_quicklinks.sh"
_toggle_module "hyprland/window" "$HOME/.config/jay/settings/waybar_window.sh"
_toggle_module "network" "$HOME/.config/jay/settings/waybar_network.sh"
_toggle_module "tray" "$HOME/.config/jay/settings/waybar_systray.sh"

# -----------------------------------------------------
# Loading the configuration
# -----------------------------------------------------

config_file="config"
style_file="style.css"

# Standard files can be overwritten with an existing config-custom or style-custom.css
if [ -f ~/.config/waybar/themes${arrThemes[0]}/config-custom ]; then
    config_file="config-custom"
fi
if [ -f ~/.config/waybar/themes${arrThemes[1]}/style-custom.css ]; then
    style_file="style-custom.css"
fi

# Check if waybar-disabled file exists
if [ ! -f $HOME/.config/jay/settings/waybar-disabled ]; then
    HYPRLAND_SIGNATURE=$(hyprctl instances -j | jq -r '.[0].instance')
    HYPRLAND_INSTANCE_SIGNATURE="$HYPRLAND_SIGNATURE" waybar -c ~/.config/waybar/themes${arrThemes[0]}/$config_file -s ~/.config/waybar/themes${arrThemes[1]}/$style_file &
    # env GTK_DEBUG=interactive waybar -c ~/.config/waybar/themes${arrThemes[0]}/$config_file -s ~/.config/waybar/themes${arrThemes[1]}/$style_file &
else
    echo ":: Waybar disabled"
fi

# Explicitly release the lock (optional) -> flock releases on exit
flock -u 200
exec 200>&-