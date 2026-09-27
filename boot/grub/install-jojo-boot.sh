#!/bin/bash
# ============================================================
# JoJo's Bizarre Adventure Boot Theme Installer
# "I, Giorno Giovanna, have a dream... to customize this boot."
# ============================================================

set -e

REAL_HOME="/home/${SUDO_USER:-$USER}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

GRUB_THEME_SRC="$SCRIPT_DIR/jojo-bizarre"
[ ! -d "$GRUB_THEME_SRC" ] && GRUB_THEME_SRC="$REAL_HOME/.config/.dotfiles/grub/jojo-bizarre"
GRUB_THEME_DEST="/boot/grub/themes/jojo-bizarre"

PLYMOUTH_THEME_SRC="$DOTFILES_DIR/boot/plymouth/jojo-bizarre"
[ ! -d "$PLYMOUTH_THEME_SRC" ] && PLYMOUTH_THEME_SRC="$REAL_HOME/.config/.dotfiles/plymouth/jojo-bizarre"
PLYMOUTH_THEME_DEST="/usr/share/plymouth/themes/jojo-bizarre"

RED='\033[0;31m'
GOLD='\033[0;33m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${PURPLE}╔══════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║${NC}  ${GOLD}ゴゴゴ JoJo Boot Theme Installer ゴゴゴ${NC}   ${PURPLE}║${NC}"
echo -e "${PURPLE}╚══════════════════════════════════════════════╝${NC}"
echo ""

# ---- GRUB THEME ----
echo -e "${GOLD}[1/4]${NC} Installing GRUB theme..."

if [ ! -d "$GRUB_THEME_SRC" ]; then
    echo -e "${RED}Error: GRUB theme source not found at $GRUB_THEME_SRC${NC}"
    exit 1
fi

sudo mkdir -p "$GRUB_THEME_DEST"
sudo cp -r "$GRUB_THEME_SRC"/* "$GRUB_THEME_DEST"/
echo "  → Theme files copied to $GRUB_THEME_DEST"

echo -e "${GOLD}[2/4]${NC} Configuring GRUB..."

# Backup existing grub config
sudo cp /etc/default/grub /etc/default/grub.bak.$(date +%Y%m%d%H%M%S)

# Set the GRUB theme
if grep -q "^GRUB_THEME=" /etc/default/grub; then
    sudo sed -i "s|^GRUB_THEME=.*|GRUB_THEME=\"$GRUB_THEME_DEST/theme.txt\"|" /etc/default/grub
elif grep -q "^#GRUB_THEME=" /etc/default/grub; then
    sudo sed -i "s|^#GRUB_THEME=.*|GRUB_THEME=\"$GRUB_THEME_DEST/theme.txt\"|" /etc/default/grub
else
    echo "GRUB_THEME=\"$GRUB_THEME_DEST/theme.txt\"" | sudo tee -a /etc/default/grub > /dev/null
fi

# Ensure graphical mode
if grep -q "^GRUB_GFXMODE=" /etc/default/grub; then
    sudo sed -i 's|^GRUB_GFXMODE=.*|GRUB_GFXMODE=auto|' /etc/default/grub
fi

# Disable terminal output to use graphical theme
if grep -q "^GRUB_TERMINAL_OUTPUT=" /etc/default/grub; then
    sudo sed -i 's|^GRUB_TERMINAL_OUTPUT=|#GRUB_TERMINAL_OUTPUT=|' /etc/default/grub
fi

# Comment out GRUB_TERMINAL_INPUT to allow graphical theme
if grep -q "^GRUB_TERMINAL_INPUT=" /etc/default/grub; then
    sudo sed -i 's|^GRUB_TERMINAL_INPUT=|#GRUB_TERMINAL_INPUT=|' /etc/default/grub
fi

# Regenerate GRUB config
sudo grub-mkconfig -o /boot/grub/grub.cfg
echo "  → GRUB configuration updated"

# ---- PLYMOUTH THEME ----
echo -e "${GOLD}[3/4]${NC} Installing Plymouth theme..."

# Check if plymouth is installed
if ! pacman -Qs plymouth > /dev/null 2>&1; then
    echo "  → Installing Plymouth..."
    sudo pacman -S --noconfirm plymouth
fi

if [ ! -d "$PLYMOUTH_THEME_SRC" ]; then
    echo -e "${RED}Warning: Plymouth theme source not found at $PLYMOUTH_THEME_SRC${NC}"
    echo "  → Skipping Plymouth installation"
else
    sudo mkdir -p "$PLYMOUTH_THEME_DEST"
    sudo cp -r "$PLYMOUTH_THEME_SRC"/* "$PLYMOUTH_THEME_DEST"/
    echo "  → Plymouth theme files copied"

    # Set as default theme
    sudo plymouth-set-default-theme -R jojo-bizarre
    echo "  → Plymouth default theme set to jojo-bizarre"
fi

echo -e "${GOLD}[4/4]${NC} Configuring kernel parameters for Plymouth..."

# Add quiet splash to kernel parameters if not present
CURRENT_CMDLINE=$(grep "^GRUB_CMDLINE_LINUX_DEFAULT=" /etc/default/grub | sed 's/.*="\(.*\)"/\1/')
if ! echo "$CURRENT_CMDLINE" | grep -q "splash"; then
    NEW_CMDLINE="$CURRENT_CMDLINE splash"
    sudo sed -i "s|^GRUB_CMDLINE_LINUX_DEFAULT=.*|GRUB_CMDLINE_LINUX_DEFAULT=\"$NEW_CMDLINE\"|" /etc/default/grub
    sudo grub-mkconfig -o /boot/grub/grub.cfg
    echo "  → Added 'splash' to kernel parameters"
fi

# Add plymouth hook to mkinitcpio if not present
if ! grep -q "plymouth" /etc/mkinitcpio.conf; then
    # Insert plymouth after base in HOOKS
    sudo sed -i 's/\(HOOKS=(base\)/\1 plymouth/' /etc/mkinitcpio.conf
    sudo mkinitcpio -P
    echo "  → Added plymouth hook to initramfs"
fi

echo ""
echo -e "${PURPLE}╔══════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║${NC}  ${GOLD}✨ Installation Complete! ✨${NC}                 ${PURPLE}║${NC}"
echo -e "${PURPLE}║${NC}                                              ${PURPLE}║${NC}"
echo -e "${PURPLE}║${NC}  ${NC}GRUB theme: $GRUB_THEME_DEST${NC}"
echo -e "${PURPLE}║${NC}  ${NC}Plymouth:   $PLYMOUTH_THEME_DEST${NC}"
echo -e "${PURPLE}║${NC}                                              ${PURPLE}║${NC}"
echo -e "${PURPLE}║${NC}  ${GOLD}Reboot to see your Stand Power!${NC}             ${PURPLE}║${NC}"
echo -e "${PURPLE}╚══════════════════════════════════════════════╝${NC}"
