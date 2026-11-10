#!/usr/bin/env bash
#  ╔══════════════════════════════════════════════════════════╗
#  ║           Vijay's Arch Linux Dotfiles Installer          ║
#  ║          Hyprland • Zsh • Bash • Neovim • Tmux           ║
#  ╚══════════════════════════════════════════════════════════╝
#
#  ./install.sh                  interactive menu
#  ./install.sh shell            zsh + bash + starship (deps + configs + zinit + chsh)
#  ./install.sh shell tmux editors   any mix of groups/steps
#  ./install.sh all              everything (full machine restore)
#  ./install.sh --list           show groups and what each links
#  ./install.sh --dry-run shell  show what would happen, change nothing
#  ./install.sh --no-pkgs shell  only link configs, don't install packages
#
#  Groups (from manifest.txt): shell terminal tmux editors dev hyprland theme misc
#  Steps:  packages  services  dev-tools  boot
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST="$DOTFILES_DIR/manifest.txt"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"
DRY_RUN=0
NO_PKGS=0

info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[✓]${NC} $1"; }
warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
error()   { echo -e "${RED}[✗]${NC} $1"; }
run()     { if (( DRY_RUN )); then echo -e "  ${CYAN}would run:${NC} $*"; else "$@"; fi; }

ask() {
    local response
    echo -en "${CYAN}[?]${NC} $1 [Y/n] "
    read -r response
    [[ -z "$response" || "$response" =~ ^[Yy] ]]
}

CFG_GROUPS=(shell terminal tmux editors dev hyprland theme misc)
STEPS=(packages services dev-tools boot)

declare -A DESC=(
    [shell]="Zsh (zinit+fzf-tab), Bash (modular ~/.config/bashrc), Starship, env files"
    [terminal]="Ghostty, Kitty, Fastfetch (+themes), Btop"
    [tmux]="tmux.conf + TPM plugins + tmux-sessionizer"
    [editors]="Neovim (lazy.nvim), Zed, VS Code settings, gdbinit"
    [dev]="gitconfig, npmrc, Lazygit, Lazydocker, OpenCode"
    [hyprland]="Hyprland, Waybar, Rofi, Walker, SwayNC, Wlogout, Quickshell, Matugen, nwg-dock, Jay/ML4W, wallpapers"
    [theme]="GTK3/4, Qt6ct, nwg-look, xsettingsd"
    [misc]="Fcitx5, mimeapps, XDG user dirs, pavucontrol, Chromium/Edge Wayland flags, Spotify theme"
    [packages]="All pacman + AUR packages (packages.txt / packages-aur.txt)"
    [services]="Enable systemd services + SDDM theme"
    [dev-tools]="npm globals, Rust, Bun, VS Code extensions (scripts/setup-dev-tools.sh)"
    [boot]="JoJo GRUB + Plymouth themes (sudo)"
)

# Minimal packages each group needs, so `./install.sh shell` works on a bare Arch box
declare -A GROUP_PKGS=(
    [shell]="zsh bash bash-completion starship fzf eza bat zoxide fastfetch git"
    [terminal]="ghostty kitty fastfetch btop"
    [tmux]="tmux git fzf"
    [editors]="neovim ripgrep fd git"
    [dev]="git git-delta lazygit npm"
    [hyprland]="hyprland hypridle hyprlock waybar rofi swaync wlogout matugen awww swayosd satty wf-recorder grim slurp grimblast-git"
    [theme]="nwg-look qt6ct xsettingsd"
    [misc]="fcitx5 fcitx5-configtool xdg-user-dirs pavucontrol"
)

banner() {
    echo -e "${BOLD}${CYAN}"
    echo '    ╔═══════════════════════════════════════════════╗'
    echo '    ║     🏔️  Vijay Arch Dotfiles Installer  🏔️     ║'
    echo '    ║      Hyprland • Zsh • Bash • Neovim • Tmux    ║'
    echo '    ╚═══════════════════════════════════════════════╝'
    echo -e "${NC}  ${BOLD}Dotfiles:${NC} $DOTFILES_DIR"
    if (( DRY_RUN )); then echo -e "  ${YELLOW}DRY RUN — nothing will be changed${NC}"; fi
    echo
}

# ─── Packages ────────────────────────────────────────────────
ensure_yay() {
    command -v yay &>/dev/null && return
    warn "yay not found — installing it"
    run sudo pacman -S --needed --noconfirm git base-devel
    local tmp; tmp=$(mktemp -d)
    run git clone https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
    (( DRY_RUN )) || (cd "$tmp/yay-bin" && makepkg -si --noconfirm)
    rm -rf "$tmp"
}

# Install a list of packages: repo packages via pacman, the rest via yay
install_pkgs() {
    local repo=() aur=() p
    for p in "$@"; do
        pacman -Q "$p" &>/dev/null && continue
        if pacman -Si "$p" &>/dev/null; then repo+=("$p"); else aur+=("$p"); fi
    done
    if (( ${#repo[@]} )); then info "pacman: ${repo[*]}"; run sudo pacman -S --needed --noconfirm "${repo[@]}"; fi
    if (( ${#aur[@]} ));  then ensure_yay; info "yay: ${aur[*]}"; run yay -S --needed --noconfirm "${aur[@]}"; fi
    (( ${#repo[@]} + ${#aur[@]} )) || success "packages already installed"
}

enable_multilib() {
    if grep -q '^\[multilib\]' /etc/pacman.conf; then return; fi
    info "Enabling the multilib repo (needed for steam / lib32 packages)"
    run sudo sed -i '/^#\[multilib\]/,/^#Include/ s/^#//' /etc/pacman.conf
}

# Drop GPU packages for hardware this PC doesn't have
filter_hardware() {
    local gpus; gpus=$(lspci 2>/dev/null | grep -iE 'vga|3d|display')
    local p
    while read -r p; do
        case $p in
            *nvidia*)        grep -qi nvidia <<< "$gpus" || { warn "skip $p (no NVIDIA GPU)"; continue; } ;;
            *vulkan-intel*|intel-media-driver)
                             grep -qi intel  <<< "$gpus" || { warn "skip $p (no Intel GPU)"; continue; } ;;
        esac
        echo "$p"
    done
}

install_all_packages() {
    info "Installing every package from packages.txt + packages-aur.txt"
    enable_multilib
    run sudo pacman -Syu --noconfirm
    mapfile -t native < <(grep -v '^\s*#' "$DOTFILES_DIR/packages.txt" | grep . | filter_hardware)
    if ! run sudo pacman -S --needed --noconfirm "${native[@]}"; then
        warn "Bulk install failed — retrying one by one so one bad package can't block the rest"
        local p failed=()
        for p in "${native[@]}"; do sudo pacman -S --needed --noconfirm "$p" &>/dev/null || failed+=("$p"); done
        (( ${#failed[@]} )) && error "Could not install: ${failed[*]}"
    fi
    ensure_yay
    mapfile -t aur < <(grep -v '^\s*#' "$DOTFILES_DIR/packages-aur.txt" | grep . | grep -vx yay | filter_hardware)
    if (( ${#aur[@]} )); then
        run yay -S --needed --noconfirm "${aur[@]}" || warn "Some AUR packages failed — rerun: ./install.sh packages"
    fi
    success "Packages installed"
}

# ─── Linking ─────────────────────────────────────────────────
link_one() {
    local src="$DOTFILES_DIR/$1" dest="$HOME/$2"
    [[ -e $src ]] || { warn "not in repo, skipping: $1"; return; }
    if [[ -L $dest && $(readlink "$dest") == "$src" ]]; then success "~/$2 (already linked)"; return; fi
    if [[ -e $dest || -L $dest ]]; then
        local bk="$BACKUP_DIR/$2"
        run mkdir -p "$(dirname "$bk")"
        run mv "$dest" "$bk"
        warn "backed up ~/$2 → $bk"
    fi
    run mkdir -p "$(dirname "$dest")"
    run ln -s "$src" "$dest"
    success "~/$2 → $1"
}

link_group() {
    local group=$1 g r t
    info "Linking group: ${BOLD}$group${NC}"
    while read -r g r t; do
        [[ -z $g || $g == \#* || $g != "$group" ]] && continue
        link_one "$r" "$t"
    done < "$MANIFEST"
}

# ─── Group post-setup ────────────────────────────────────────
post_shell() {
    local zinit="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
    if [[ ! -d $zinit ]]; then
        info "Installing Zinit"
        run mkdir -p "$(dirname "$zinit")"
        run git clone https://github.com/zdharma-continuum/zinit.git "$zinit"
    fi
    if [[ $(getent passwd "$USER" | cut -d: -f7) != */zsh ]]; then
        if ask "Make zsh your default shell?"; then run chsh -s "$(command -v zsh)"; fi
    fi
    success "Shell ready — open a new terminal (zinit installs plugins on first start)"
}

post_tmux() {
    if [[ ! -d $HOME/.tmux/plugins/tpm ]]; then
        info "Installing TPM"
        run git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    fi
    [[ -x $HOME/.tmux/plugins/tpm/bin/install_plugins ]] && run "$HOME/.tmux/plugins/tpm/bin/install_plugins" >/dev/null || true
    run chmod +x "$DOTFILES_DIR/scripts/tmux-sessionizer"
    success "tmux ready"
}

post_dev() {
    run mkdir -p "$HOME/.npm-global"
}

post_hyprland() {
    run chmod +x "$DOTFILES_DIR"/scripts/jay-dotfiles-* "$DOTFILES_DIR"/hypr/scripts/*.sh 2>/dev/null || true
}

install_group() {
    local group=$1
    echo; echo -e "${BOLD}━━━ $group ━━━${NC}  ${DESC[$group]}"
    read -ra pkgs <<< "${GROUP_PKGS[$group]:-}"
    if (( ${#pkgs[@]} && ! NO_PKGS )); then install_pkgs "${pkgs[@]}"; fi
    link_group "$group"
    declare -F "post_$group" >/dev/null && "post_$group"
    return 0
}

# ─── Steps ───────────────────────────────────────────────────
enable_services() {
    info "Enabling systemd services"
    local svc
    # PostgreSQL won't start until its data dir is initialised
    if pacman -Q postgresql &>/dev/null && [[ ! -f /var/lib/postgres/data/PG_VERSION ]]; then
        info "Initialising PostgreSQL data directory"
        run sudo -u postgres initdb -D /var/lib/postgres/data
    fi
    # Use docker without sudo
    if pacman -Q docker &>/dev/null && ! id -nG "$USER" | grep -qw docker; then
        run sudo usermod -aG docker "$USER" && success "added $USER to docker group (re-login)"
    fi
    for svc in bluetooth docker.socket NetworkManager ntpd postgresql sddm; do   # docker.socket = start Docker on first use
        [[ $svc == *.* ]] || svc=$svc.service; systemctl list-unit-files "$svc" &>/dev/null || { warn "$svc not installed"; continue; }
        systemctl is-enabled "$svc" &>/dev/null && { success "$svc already enabled"; continue; }
        run sudo systemctl enable "$svc" && success "enabled $svc"
    done
    if [[ -f $DOTFILES_DIR/system/sddm.conf ]]; then
        run sudo cp "$DOTFILES_DIR/system/sddm.conf" /etc/sddm.conf && success "SDDM config installed"
    fi
}

setup_dev_tools() { run bash "$DOTFILES_DIR/scripts/setup-dev-tools.sh"; }
install_boot() {
    if [[ ! -d /boot/grub ]] || ! command -v grub-mkconfig &>/dev/null; then
        warn "GRUB not found (systemd-boot?) — skipping boot themes"; return
    fi
    run sudo bash "$DOTFILES_DIR/boot/grub/install-jojo-boot.sh"
}

do_item() {
    case $1 in
        packages)  install_all_packages ;;
        services)  enable_services ;;
        dev-tools) setup_dev_tools ;;
        boot)      install_boot ;;
        *)         if [[ -n ${DESC[$1]:-} ]]; then install_group "$1"; else error "unknown: $1 (try --list)"; exit 1; fi ;;
    esac
}

list_items() {
    local g
    echo -e "${BOLD}Config groups${NC}"
    for g in "${CFG_GROUPS[@]}"; do
        printf "  ${GREEN}%-10s${NC} %s\n" "$g" "${DESC[$g]}"
        awk -v g="$g" '$1==g {printf "               %-28s → ~/%s\n", $2, $3}' "$MANIFEST"
    done
    echo -e "\n${BOLD}System steps${NC}"
    for g in "${STEPS[@]}"; do printf "  ${GREEN}%-10s${NC} %s\n" "$g" "${DESC[$g]}"; done
}

menu() {
    local all=("${CFG_GROUPS[@]}" "${STEPS[@]}") i choice
    echo -e "${BOLD}What do you want to install?${NC}"
    for i in "${!all[@]}"; do printf "  ${CYAN}%2d)${NC} %-10s %s\n" $((i+1)) "${all[$i]}" "${DESC[${all[$i]}]}"; done
    echo -e "  ${CYAN} a)${NC} everything"
    echo -en "\nPick numbers separated by spaces (e.g. ${BOLD}1 3${NC}): "
    read -ra choice
    SELECTED=()
    for i in "${choice[@]}"; do
        if [[ $i == a ]]; then SELECTED=(packages "${CFG_GROUPS[@]}" services dev-tools boot); return; fi
        [[ $i =~ ^[0-9]+$ ]] && (( i >= 1 && i <= ${#all[@]} )) && SELECTED+=("${all[$((i-1))]}")
    done
}

preflight() {
    [[ $EUID -eq 0 ]] && { error "Run as your normal user, not root (sudo is used when needed)"; exit 1; }
    (( DRY_RUN )) && return
    [[ ${1:-1} == 0 ]] && return
    command -v sudo &>/dev/null || { error "sudo is missing: as root run  pacman -S sudo  and add yourself to wheel"; exit 1; }
    sudo -v || { error "sudo failed — is your user in the wheel group?"; exit 1; }
    # keep sudo alive for long installs
    while true; do sudo -n true; sleep 50; kill -0 "$$" || exit; done 2>/dev/null &
    ping -c1 -W3 archlinux.org &>/dev/null || warn "No internet? Package steps will fail (connect with nmtui / iwctl)"
}

main() {
    local args=()
    for a in "$@"; do
        case $a in
            --dry-run|-n) DRY_RUN=1 ;;
            --no-pkgs)    NO_PKGS=1 ;;
            --list|-l)    list_items; exit 0 ;;
            --help|-h)    sed -n '6,16p' "${BASH_SOURCE[0]}" | sed 's/^#  \{0,1\}//'; exit 0 ;;
            all|--all)    args+=(packages "${CFG_GROUPS[@]}" services dev-tools boot) ;;
            --dotfiles)   args+=("${CFG_GROUPS[@]}") ;;   # old flag: link everything
            --dev)        args+=(dev-tools) ;;            # old flag: dev tools script
            --*)          args+=("${a#--}") ;;            # --packages, --services, --boot
            *)            args+=("$a") ;;
        esac
    done

    banner
    [[ -f /etc/arch-release ]] || warn "This doesn't look like Arch Linux — package steps may fail."

    if (( ${#args[@]} == 0 )); then menu; args=("${SELECTED[@]}"); fi
    (( ${#args[@]} )) || { warn "nothing selected"; exit 0; }

    # sudo is only needed for packages / services / boot / chsh
    local need_sudo=0 i
    for i in "${args[@]}"; do
        [[ $i == packages || $i == services || $i == boot || $i == dev-tools ]] && need_sudo=1
        [[ -n ${GROUP_PKGS[$i]:-} ]] && (( ! NO_PKGS )) && need_sudo=1
    done
    preflight "$need_sudo"

    local item; for item in "${args[@]}"; do do_item "$item"; done

    echo -e "\n${BOLD}${GREEN}🎉 Done:${NC} ${args[*]}"
    [[ -d $BACKUP_DIR ]] && echo -e "${YELLOW}Old files backed up to:${NC} $BACKUP_DIR"
    echo "Tips: open nvim to let lazy.nvim install plugins · tmux: prefix + I · log out to apply shell change"
}

main "$@"
