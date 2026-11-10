#!/usr/bin/env bash
# One-time performance fixes for the IdeaPad S540 (Intel UHD 620 + GeForce MX250).
# Run as your user:  ~/Projects/dotfiles/scripts/fix-performance.sh
set -euo pipefail
ok() { echo -e "\033[0;32m[✓]\033[0m $1"; }

sudo -v

# 1. nvidia-open can't drive the MX250 (Pascal is too old for it): the driver fails to load,
#    and the card sits powered-on doing nothing. Remove it; nouveau then loads and
#    puts the card to sleep when nothing uses it.
if pacman -Q nvidia-open &>/dev/null; then
    sudo pacman -Rns --noconfirm nvidia-open nvidia-utils lib32-nvidia-utils
    ok "Removed unusable NVIDIA driver"
fi

# 2. Let the NVIDIA card power down when idle (also applied right now)
echo 'ACTION=="add|bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030[0-2]*", TEST=="power/control", ATTR{power/control}="auto"' \
    | sudo tee /etc/udev/rules.d/80-nvidia-runtime-pm.rules >/dev/null
for d in /sys/bus/pci/devices/*; do
    [[ $(cat "$d/vendor") == 0x10de ]] && echo auto | sudo tee "$d/power/control" >/dev/null
done
ok "NVIDIA card allowed to sleep when idle"

# 3. Docker: start on first use instead of at every boot (docker commands work the same)
if systemctl is-enabled docker.service &>/dev/null; then
    sudo systemctl disable docker.service containerd.service 2>/dev/null || true
    sudo systemctl enable docker.socket
    ok "Docker now starts on demand"
fi

echo
echo "Done. Reboot now to clear the stuck Intel graphics worker and load the updated Hyprland:"
echo "    systemctl reboot"
