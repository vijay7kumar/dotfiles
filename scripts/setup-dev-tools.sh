#!/usr/bin/env bash
#  ╔══════════════════════════════════════════════════════════╗
#  ║            Development Tools Setup Script                ║
#  ║        npm globals • cargo • bun • pip • flatpaks        ║
#  ╚══════════════════════════════════════════════════════════╝

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[✓]${NC} $1"; }
warn()    { echo -e "${YELLOW}[!]${NC} $1"; }

# ─── NPM Global Packages ─────────────────────────────────────
setup_npm() {
    info "Setting up npm global packages..."

    # Create npm global dir (avoid sudo for global installs)
    mkdir -p "$HOME/.npm-global"
    npm config set prefix "$HOME/.npm-global" 2>/dev/null || true

    local npm_packages=(
        "eslint"
        "prettier"
        "typescript"
        "typescript-language-server"
    )

    for pkg in "${npm_packages[@]}"; do
        if npm list -g "$pkg" &>/dev/null; then
            success "$pkg already installed"
        else
            info "Installing $pkg..."
            npm install -g "$pkg"
            success "Installed $pkg"
        fi
    done
}

# ─── Rust / Cargo Setup ──────────────────────────────────────
setup_rust() {
    info "Setting up Rust toolchain..."

    if ! command -v rustup &>/dev/null; then
        warn "rustup not found. Installing..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
    fi

    # Ensure stable toolchain
    rustup default stable
    rustup component add rust-analyzer clippy rustfmt

    success "Rust toolchain configured!"
}

# ─── Bun Setup ────────────────────────────────────────────────
setup_bun() {
    info "Setting up Bun..."

    if ! command -v bun &>/dev/null; then
        warn "Bun not found. Installing..."
        curl -fsSL https://bun.sh/install | bash
        success "Bun installed!"
    else
        success "Bun already installed ($(bun --version))"
    fi
}

# ─── Python Virtual Env Setup ────────────────────────────────
setup_python() {
    info "Setting up Python dev tools..."

    # Ensure pip user-installed tools
    local pip_tools=(
        "black"
        "pyright"
        "virtualenv"
    )

    for tool in "${pip_tools[@]}"; do
        if command -v "$tool" &>/dev/null || pacman -Qq "python-$tool" &>/dev/null 2>&1; then
            success "$tool available"
        else
            info "Installing $tool via pip..."
            pip install --user "$tool" 2>/dev/null || warn "Install python-$tool via pacman instead"
        fi
    done
}

# ─── VS Code Extensions ──────────────────────────────────────
setup_vscode() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local dotfiles_dir="$(dirname "$script_dir")"
    local extensions_file="$dotfiles_dir/vscode/extensions.txt"

    if ! command -v code &>/dev/null; then
        warn "VS Code not found. Skipping extensions."
        return
    fi

    if [[ ! -f "$extensions_file" ]]; then
        warn "vscode/extensions.txt not found. Skipping."
        return
    fi

    info "Installing VS Code extensions..."
    while IFS= read -r ext; do
        [[ -z "$ext" ]] && continue
        if code --list-extensions | grep -qi "^${ext}$"; then
            success "Extension $ext already installed"
        else
            code --install-extension "$ext" --force
            success "Installed $ext"
        fi
    done < "$extensions_file"
}

# ─── Main ─────────────────────────────────────────────────────
main() {
    echo ""
    echo -e "${BLUE}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║     🛠️  Dev Tools Setup                       ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════════╝${NC}"
    echo ""

    setup_npm
    echo ""
    setup_rust
    echo ""
    setup_bun
    echo ""
    setup_python
    echo ""
    setup_vscode
    echo ""

    echo -e "${GREEN}✨ All dev tools configured!${NC}"
}

main "$@"
