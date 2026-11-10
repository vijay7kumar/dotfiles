#!/usr/bin/env bash
#     _    _ _  __ _             _
#    / \  | | |/ _| | ___   __ _| |_
#   / _ \ | | | |_| |/ _ \ / _` | __|
#  / ___ \| | |  _| | (_) | (_| | |_
# /_/   \_\_|_|_| |_|\___/ \__,_|\__|
#

exec "$HOME/.config/jay/scripts/jay-toggle-allfloat"  # workspaceopt was removed in Lua mode

# Notifications
source "$HOME/.config/jay/scripts/jay-notification-handler"

notify_user \
        --a "System" \
        --m "Windows on this workspace toggled to floating/tiling"
