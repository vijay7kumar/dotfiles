#!/usr/bin/env bash
# One-time: replace the astronaut/spaceship login screen with one that follows
# your wallpaper and colours. Run:  ~/.config/hypr/scripts/sddm-setup.sh
set -euo pipefail

# Started with sudo? Re-run as the real user, so $HOME and file ownership are right.
if [[ $EUID -eq 0 ]]; then
    [[ -n ${SUDO_USER:-} && $SUDO_USER != root ]] || { echo "Run this as your normal user, not root."; exit 1; }
    exec sudo -u "$SUDO_USER" -H "$(getent passwd "$SUDO_USER" | cut -d: -f6)/.config/hypr/scripts/sddm-setup.sh"
fi
SRC=/usr/share/sddm/themes/sddm-astronaut-theme
DST=/usr/share/sddm/themes/rice
[[ -d $SRC ]] || { echo "sddm-astronaut-theme is not installed (yay -S sddm-astronaut-theme)"; exit 1; }
sudo -v

# Own copy of the theme so package updates can't reset it (videos/extra backgrounds left out)
sudo rm -rf "$DST"
sudo mkdir -p "$DST"
sudo cp -r "$SRC"/. "$DST"/
sudo find "$DST/Backgrounds" -type f -delete
sudo find "$DST/Themes" -type f -delete
sudo sed -i 's|^ConfigFile=.*|ConfigFile=Themes/rice.conf|; s|^Name=.*|Name=Rice|' "$DST/metadata.desktop"

# The two files that change with the wallpaper belong to you; SDDM only needs to read them
sudo install -o "$USER" -g "$(id -gn)" -m 644 /dev/null "$DST/Backgrounds/rice.jpg"
sudo install -o "$USER" -g "$(id -gn)" -m 644 /dev/null "$DST/Themes/rice.conf"
"$HOME/.config/hypr/scripts/sddm-sync.sh"
[[ -s $DST/Themes/rice.conf && -s $DST/Backgrounds/rice.jpg ]] || { echo "sync failed — theme files are empty, not switching"; exit 1; }

# Switch SDDM to it
sudo cp /etc/sddm.conf "/etc/sddm.conf.bak.$(date +%Y%m%d%H%M%S)"
if grep -q '^Current=' /etc/sddm.conf; then sudo sed -i 's|^Current=.*|Current=rice|' /etc/sddm.conf
else printf '[Theme]\nCurrent=rice\n' | sudo tee -a /etc/sddm.conf >/dev/null; fi
echo "Done — the login screen now uses your wallpaper. Preview without rebooting:"
echo "    sddm-greeter-qt6 --test-mode --theme $DST"
