#!/usr/bin/env bash
#  ╔══════════════════════════════════════════════════════════╗
#  ║           Vijay's Arch Linux Dotfiles Installer          ║
#  ║          Hyprland • Zsh • Neovim • Ghostty • Tmux       ║
#  ╚══════════════════════════════════════════════════════════╝

set -euo pipefail

# ─── Colors ──────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"

# ─── Helper Functions ────────────────────────────────────────
info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[✓]${NC} $1"; }
warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
error()   { echo -e "${RED}[✗]${NC} $1"; }

ask() {
    local prompt="$1"
    local response
    echo -en "${CYAN}[?]${NC} ${prompt} [Y/n] "
    read -r response
    [[ -z "$response" || "$response" =~ ^[Yy] ]]
}

banner() {
    echo -e "${BOLD}${CYAN}"
    echo '    ╔═══════════════════════════════════════════════╗'
    echo '    ║     🏔️  Vijay Arch Dotfiles Installer  🏔️     ║'
    echo '    ║         Hyprland • Zsh • Neovim • Tmux       ║'
    echo '    ╚═══════════════════════════════════════════════╝'
    echo -e "${NC}"
    echo -e "  ${BOLD}Dotfiles dir:${NC} $DOTFILES_DIR"
    echo -e "  ${BOLD}Backup dir:${NC}   $BACKUP_DIR"
    echo ""
}

# ─── Backup existing file before symlinking ──────────────────
backup_and_link() {
    local src="$1"
    local dest="$2"

    # Create parent directory
    mkdir -p "$(dirname "$dest")"

    # Backup existing file/dir
    if [[ -e "$dest" || -L "$dest" ]]; then
        mkdir -p "$BACKUP_DIR"
        local backup_path="$BACKUP_DIR/$(basename "$dest")"
        warn "Backing up existing $(basename "$dest") → $backup_path"
        mv "$dest" "$backup_path"
    fi

    ln -sf "$src" "$dest"
    success "Linked $(basename "$dest")"
}

# ═══════════════════════════════════════════════════════════
# STEP 1: Install packages
# ═══════════════════════════════════════════════════════════
install_packages() {
    info "Installing official packages via pacman..."

    if [[ ! -f "$DOTFILES_DIR/packages.txt" ]]; then
        error "packages.txt not found!"
        return 1
    fi

    # Filter out already installed packages
    local to_install
    to_install=$(comm -23 \
        <(sort "$DOTFILES_DIR/packages.txt") \
        <(pacman -Qqe | sort) \
    )

    if [[ -n "$to_install" ]]; then
        local count
        count=$(echo "$to_install" | wc -l)
        info "Installing $count official packages..."
        echo "$to_install" | sudo pacman -S --needed --noconfirm -
        success "Official packages installed!"
    else
        success "All official packages already installed."
    fi
}

install_aur_packages() {
    info "Installing AUR packages via yay..."

    # Ensure yay is installed
    if ! command -v yay &>/dev/null; then
        warn "yay not found. Installing yay first..."
        local tmpdir
        tmpdir=$(mktemp -d)
        git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"
        (cd "$tmpdir/yay" && makepkg -si --noconfirm)
        rm -rf "$tmpdir"
        success "yay installed!"
    fi

    if [[ ! -f "$DOTFILES_DIR/packages-aur.txt" ]]; then
        error "packages-aur.txt not found!"
        return 1
    fi

    local to_install
    to_install=$(comm -23 \
        <(sort "$DOTFILES_DIR/packages-aur.txt") \
        <(pacman -Qqm | sort) \
    )

    if [[ -n "$to_install" ]]; then
        local count
        count=$(echo "$to_install" | wc -l)
        info "Installing $count AUR packages..."
        echo "$to_install" | xargs yay -S --needed --noconfirm
        success "AUR packages installed!"
    else
        success "All AUR packages already installed."
    fi
}

# ═══════════════════════════════════════════════════════════
# STEP 2: Symlink dotfiles
# ═══════════════════════════════════════════════════════════
link_dotfiles() {
    info "Symlinking dotfiles..."

    # Shell
    backup_and_link "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"

    # Git
    backup_and_link "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"

    # Tmux
    backup_and_link "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"

    # Neovim
    backup_and_link "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"

    # Starship
    backup_and_link "$DOTFILES_DIR/starship/starship.toml" "$HOME/.config/starship.toml"

    # Ghostty
    backup_and_link "$DOTFILES_DIR/ghostty" "$HOME/.config/ghostty"

    # Kitty
    backup_and_link "$DOTFILES_DIR/kitty" "$HOME/.config/kitty"

    # Fastfetch
    backup_and_link "$DOTFILES_DIR/fastfetch" "$HOME/.config/fastfetch"

    # GTK
    backup_and_link "$DOTFILES_DIR/gtk-3.0" "$HOME/.config/gtk-3.0"
    backup_and_link "$DOTFILES_DIR/gtk-4.0" "$HOME/.config/gtk-4.0"

    # Hyprland
    backup_and_link "$DOTFILES_DIR/hypr" "$HOME/.config/hypr"

    # Rofi
    backup_and_link "$DOTFILES_DIR/rofi" "$HOME/.config/rofi"

    # Waybar
    backup_and_link "$DOTFILES_DIR/waybar" "$HOME/.config/waybar"

    # SwayNC
    backup_and_link "$DOTFILES_DIR/swaync" "$HOME/.config/swaync"

    # Wlogout
    backup_and_link "$DOTFILES_DIR/wlogout" "$HOME/.config/wlogout"

    # Btop
    backup_and_link "$DOTFILES_DIR/btop" "$HOME/.config/btop"

    # Zed Editor
    backup_and_link "$DOTFILES_DIR/zed/settings.json" "$HOME/.config/zed/settings.json"

    # Lazygit
    backup_and_link "$DOTFILES_DIR/lazygit/config.yml" "$HOME/.config/lazygit/config.yml"

    # Lazydocker
    backup_and_link "$DOTFILES_DIR/lazydocker/config.yml" "$HOME/.config/lazydocker/config.yml"

    # VS Code
    backup_and_link "$DOTFILES_DIR/vscode/settings.json" "$HOME/.config/Code/User/settings.json"

    # Qt6ct
    backup_and_link "$DOTFILES_DIR/qt6ct" "$HOME/.config/qt6ct"

    # xsettingsd
    backup_and_link "$DOTFILES_DIR/xsettingsd/xsettingsd.conf" "$HOME/.config/xsettingsd/xsettingsd.conf"

    # nwg-dock-hyprland
    backup_and_link "$DOTFILES_DIR/nwg-dock-hyprland" "$HOME/.config/nwg-dock-hyprland"

    # Waypaper
    backup_and_link "$DOTFILES_DIR/waypaper/config.ini" "$HOME/.config/waypaper/config.ini"

    # OpenCode
    backup_and_link "$DOTFILES_DIR/opencode/opencode.jsonc" "$HOME/.config/opencode/opencode.jsonc"

    # Browser flags (Wayland support)
    backup_and_link "$DOTFILES_DIR/chromium-flags.conf" "$HOME/.config/chromium-flags.conf"
    backup_and_link "$DOTFILES_DIR/edge-flags.conf" "$HOME/.config/edge-flags.conf"

    # Bash profile
    backup_and_link "$DOTFILES_DIR/.bash_profile" "$HOME/.bash_profile"

    # Jay framework (ML4W dotfiles engine)
    backup_and_link "$DOTFILES_DIR/jay" "$HOME/.config/jay"

    # Quickshell (Wayland shell widgets)
    backup_and_link "$DOTFILES_DIR/quickshell" "$HOME/.config/quickshell"

    # Matugen (material color generation)
    backup_and_link "$DOTFILES_DIR/matugen" "$HOME/.config/matugen"

    # Environment & Shell dotfiles in $HOME
    backup_and_link "$DOTFILES_DIR/.zshenv" "$HOME/.zshenv"
    backup_and_link "$DOTFILES_DIR/.profile" "$HOME/.profile"
    backup_and_link "$DOTFILES_DIR/.npmrc" "$HOME/.npmrc"
    [[ -f "$DOTFILES_DIR/.gdbinit" ]] && backup_and_link "$DOTFILES_DIR/.gdbinit" "$HOME/.gdbinit"

    # Modular Bash config
    backup_and_link "$DOTFILES_DIR/bashrc" "$HOME/.config/bashrc"

    # Desktop utilities & Input method
    backup_and_link "$DOTFILES_DIR/fcitx5" "$HOME/.config/fcitx5"
    backup_and_link "$DOTFILES_DIR/nwg-displays" "$HOME/.config/nwg-displays"
    backup_and_link "$DOTFILES_DIR/nwg-look" "$HOME/.config/nwg-look"
    backup_and_link "$DOTFILES_DIR/sidepad" "$HOME/.config/sidepad"
    backup_and_link "$DOTFILES_DIR/jay-dotfiles-settings" "$HOME/.config/jay-dotfiles-settings"
    backup_and_link "$DOTFILES_DIR/walker" "$HOME/.config/walker"

    # XDG MIME and directories
    backup_and_link "$DOTFILES_DIR/mimeapps.list" "$HOME/.config/mimeapps.list"
    backup_and_link "$DOTFILES_DIR/user-dirs.dirs" "$HOME/.config/user-dirs.dirs"
    backup_and_link "$DOTFILES_DIR/user-dirs.locale" "$HOME/.config/user-dirs.locale"
    [[ -f "$DOTFILES_DIR/pavucontrol.ini" ]] && backup_and_link "$DOTFILES_DIR/pavucontrol.ini" "$HOME/.config/pavucontrol.ini"

    # Wallpapers
    mkdir -p "$HOME/Pictures"
    backup_and_link "$DOTFILES_DIR/wallpapers" "$HOME/Pictures/Wallpapers"

    # Helper scripts
    mkdir -p "$HOME/.local/bin"
    backup_and_link "$DOTFILES_DIR/scripts/tmux-sessionizer" "$HOME/.local/bin/tmux-sessionizer"
    backup_and_link "$DOTFILES_DIR/scripts/jay-dotfiles-installer" "$HOME/.local/bin/jay-dotfiles-installer"
    backup_and_link "$DOTFILES_DIR/scripts/jay-dotfiles-settings" "$HOME/.local/bin/jay-dotfiles-settings"
    chmod +x "$HOME/.local/bin/"*

    success "All dotfiles symlinked!"
}

# ═══════════════════════════════════════════════════════════
# STEP 3: Enable systemd services
# ═══════════════════════════════════════════════════════════
enable_services() {
    info "Enabling systemd services..."

    local services=(
        "bluetooth.service"
        "docker.service"
        "NetworkManager.service"
        "NetworkManager-dispatcher.service"
        "NetworkManager-wait-online.service"
        "ntpd.service"
        "postgresql.service"
        "sddm.service"
    )

    for svc in "${services[@]}"; do
        if systemctl is-enabled "$svc" &>/dev/null; then
            success "$svc already enabled"
        else
            sudo systemctl enable "$svc"
            success "Enabled $svc"
        fi
    done

    # Configure SDDM Theme
    if [[ -f "$DOTFILES_DIR/system/sddm.conf" ]]; then
        info "Configuring SDDM Astronaut Theme..."
        sudo cp "$DOTFILES_DIR/system/sddm.conf" /etc/sddm.conf
        success "SDDM theme configured!"
    fi

    success "All services configured!"
}

# ═══════════════════════════════════════════════════════════
# STEP 4: Post-install setup
# ═══════════════════════════════════════════════════════════
post_install() {
    info "Running post-install setup..."

    # Install Tmux Plugin Manager
    if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
        info "Installing Tmux Plugin Manager (TPM)..."
        git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
        success "TPM installed! Run prefix + I inside tmux to install plugins."
    else
        success "TPM already installed."
    fi

    # Install Zinit (Zsh plugin manager)
    local zinit_dir="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
    if [[ ! -d "$zinit_dir" ]]; then
        info "Installing Zinit..."
        mkdir -p "$(dirname "$zinit_dir")"
        git clone https://github.com/zdharma-continuum/zinit.git "$zinit_dir"
        success "Zinit installed!"
    else
        success "Zinit already installed."
    fi

    # Set Zsh as default shell
    if [[ "$SHELL" != "/usr/bin/zsh" ]]; then
        info "Setting Zsh as default shell..."
        chsh -s /usr/bin/zsh
        success "Default shell set to Zsh. Log out and back in to apply."
    else
        success "Zsh is already the default shell."
    fi

    # Create npm global directory
    mkdir -p "$HOME/.npm-global"
    npm config set prefix "$HOME/.npm-global" 2>/dev/null || true

    success "Post-install setup complete!"
}

# ═══════════════════════════════════════════════════════════
# STEP 5: Dev tools setup
# ═══════════════════════════════════════════════════════════
setup_dev_tools() {
    info "Setting up development tools..."
    if [[ -f "$DOTFILES_DIR/scripts/setup-dev-tools.sh" ]]; then
        bash "$DOTFILES_DIR/scripts/setup-dev-tools.sh"
    else
        error "scripts/setup-dev-tools.sh not found!"
    fi
}

# ═══════════════════════════════════════════════════════════
# STEP 6: Boot themes setup (JoJo Grub + Plymouth)
# ═══════════════════════════════════════════════════════════
install_boot_themes() {
    info "Setting up JoJo's Bizarre Adventure Boot Themes..."
    if [[ -f "$DOTFILES_DIR/boot/grub/install-jojo-boot.sh" ]]; then
        sudo bash "$DOTFILES_DIR/boot/grub/install-jojo-boot.sh"
        success "Boot themes installed!"
    else
        warn "boot/grub/install-jojo-boot.sh not found."
    fi
}

# ═══════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════
main() {
    banner

    case "${1:-}" in
        --packages)
            install_packages
            install_aur_packages
            ;;
        --dotfiles)
            link_dotfiles
            ;;
        --services)
            enable_services
            ;;
        --dev)
            setup_dev_tools
            ;;
        --boot)
            install_boot_themes
            ;;
        --all)
            install_packages
            install_aur_packages
            link_dotfiles
            enable_services
            post_install
            setup_dev_tools
            install_boot_themes
            ;;
        *)
            # Interactive mode
            if ask "Install official packages (pacman)?"; then
                install_packages
            fi
            echo ""

            if ask "Install AUR packages (yay)?"; then
                install_aur_packages
            fi
            echo ""

            if ask "Symlink dotfiles? (existing files will be backed up)"; then
                link_dotfiles
            fi
            echo ""

            if ask "Enable systemd services?"; then
                enable_services
            fi
            echo ""

            if ask "Run post-install setup (TPM, Zinit, Zsh default)?"; then
                post_install
            fi
            echo ""

            if ask "Setup dev tools (npm globals, Rust, Bun, VS Code extensions)?"; then
                setup_dev_tools
            fi
            echo ""

            if ask "Install JoJo Grub & Plymouth boot themes? (requires sudo)"; then
                install_boot_themes
            fi
            ;;
    esac

    echo ""
    echo -e "${BOLD}${GREEN}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${GREEN}║          🎉 Installation Complete! 🎉         ║${NC}"
    echo -e "${BOLD}${GREEN}╚═══════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  ${BOLD}Next steps:${NC}"
    echo -e "    1. Log out and log back in for shell changes"
    echo -e "    2. Open tmux and press ${CYAN}prefix + I${NC} to install plugins"
    echo -e "    3. Open neovim — lazy.nvim will auto-install plugins"
    echo -e "    4. Run ${CYAN}:Mason${NC} in neovim to install LSP servers"
    echo -e "    5. Run ${CYAN}./install.sh --dev${NC} to setup dev tools separately"
    echo ""
    if [[ -d "$BACKUP_DIR" ]]; then
        echo -e "  ${YELLOW}Backups saved to:${NC} $BACKUP_DIR"
    fi
}

main "$@"
