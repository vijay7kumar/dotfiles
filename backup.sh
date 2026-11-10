#!/usr/bin/env bash
#  ╔══════════════════════════════════════════════════════════╗
#  ║   backup.sh — copy the live system INTO this repo        ║
#  ║   Uses manifest.txt. Top-level symlinks are followed.    ║
#  ╚══════════════════════════════════════════════════════════╝
#  Usage: ./backup.sh            # sync everything
#         ./backup.sh shell tmux # only these groups
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

G='\033[0;32m'; Y='\033[1;33m'; B='\033[0;34m'; NC='\033[0m'
info() { echo -e "${B}[INFO]${NC} $1"; }
ok()   { echo -e "${G}[✓]${NC} $1"; }
warn() { echo -e "${Y}[!]${NC} $1"; }

command -v rsync >/dev/null || { echo "rsync is required (sudo pacman -S rsync)"; exit 1; }

# Never copy caches, plugin checkouts, or credentials
EXCLUDES=(--exclude='.git/' --exclude='node_modules/' --exclude='plugins/'
          --exclude='*.log' --exclude='.cache/' --exclude='lazy-lock.json')

want_group() {
    [[ ${#GROUPS_WANTED[@]} -eq 0 ]] && return 0
    local g; for g in "${GROUPS_WANTED[@]}"; do [[ $g == "$1" ]] && return 0; done
    return 1
}
GROUPS_WANTED=("$@")

# ─── 1. Dotfiles from manifest ───────────────────────────────
info "Syncing dotfiles from \$HOME → repo"
while read -r group repo target; do
    [[ -z $group || $group == \#* ]] && continue
    want_group "$group" || continue
    src="$HOME/$target"
    # Skip if the target IS a symlink into this repo (already in sync)
    if [[ -L $src && $(readlink -f "$src") == "$DOTFILES_DIR/$repo" ]]; then
        ok "$repo (linked to repo)"; continue
    fi
    if [[ ! -e $src ]]; then warn "missing on system: ~/$target"; continue; fi
    mkdir -p "$(dirname "$repo")"
    if [[ -d $src ]]; then
        rsync -a --delete "${EXCLUDES[@]}" "$src/" "$repo/"   # trailing / follows top-level link, keeps inner links
    else
        rsync -aL "$src" "$repo"
    fi
    ok "$repo"
done < manifest.txt

# Groups-only run stops here
[[ ${#GROUPS_WANTED[@]} -gt 0 ]] && exit 0

# ─── 2. Package lists ────────────────────────────────────────
info "Updating package lists"
pacman -Qqen > packages.txt
pacman -Qqem > packages-aur.txt
ok "packages.txt ($(wc -l < packages.txt)) / packages-aur.txt ($(wc -l < packages-aur.txt))"

if command -v code >/dev/null; then
    code --list-extensions > vscode/extensions.txt 2>/dev/null && ok "vscode/extensions.txt"
fi

# ─── 3. System files from /etc (read-only copies) ────────────
info "Copying system configs from /etc"
mkdir -p system
for pair in "/etc/pacman.conf:pacman.conf" "/etc/mkinitcpio.conf:mkinitcpio.conf" \
            "/etc/sddm.conf:sddm.conf" "/etc/default/grub:grub.default" \
            "/etc/plymouth/plymouthd.conf:plymouthd.conf"; do
    src=${pair%%:*}; dst=system/${pair##*:}
    [[ -r $src ]] && cp "$src" "$dst" && ok "$dst"
done

echo
info "Done. Review with:  git -C \"$DOTFILES_DIR\" status"
