#  ╔══════════════════════════════════════════════════════════╗
#  ║                    Vijay's Zsh Config                   ║
#  ║               Zinit + Starship + UX Power               ║
#  ╚══════════════════════════════════════════════════════════╝

# Exit if not interactive
[[ $- != *i* ]] && return

# ─── Zinit Installation ─────────────────────────────────────
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Auto-install zinit if missing
if [[ ! -d "$ZINIT_HOME" ]]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"

# ─── Plugins (loaded via Zinit) ─────────────────────────────
# Completions — extra completion definitions
zinit light zsh-users/zsh-completions

# fzf-tab — replace zsh's default completion with fzf
zinit light Aloxaf/fzf-tab

# Autosuggestions — ghost text from history (accept with →)
zinit light zsh-users/zsh-autosuggestions

# Syntax highlighting — colors commands as you type
zinit light zsh-users/zsh-syntax-highlighting

# History substring search — type partial + ↑/↓ to search
zinit light zsh-users/zsh-history-substring-search

# ─── Completion System ──────────────────────────────────────
autoload -Uz compinit && compinit
zinit cdreplay -q

# Style: case-insensitive, partial-word, and substring completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' special-dirs true

# fzf-tab styling
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --icons --color=always $realpath'
zstyle ':fzf-tab:complete:ls:*' fzf-preview 'eza -1 --icons --color=always $realpath'
zstyle ':fzf-tab:*' fzf-flags --height=40% --layout=reverse --border

# ─── History ─────────────────────────────────────────────────
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000

# setopt APPEND_HISTORY          # Removed: implied by SHARE_HISTORY
setopt SHARE_HISTORY           # Share history across sessions
# setopt INC_APPEND_HISTORY      # Removed: implied by SHARE_HISTORY
# setopt HIST_IGNORE_DUPS        # Removed: implied by HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_ALL_DUPS    # Remove older duplicate entries
setopt HIST_FIND_NO_DUPS       # Don't show dupes when searching
setopt HIST_REDUCE_BLANKS      # Remove extra blanks
setopt HIST_IGNORE_SPACE       # Skip commands starting with space (privacy)
setopt HIST_VERIFY             # Show expanded history before executing
setopt EXTENDED_HISTORY        # Save timestamps

# ─── Key Bindings (UX) ──────────────────────────────────────
# Use emacs keybindings as base (more intuitive for terminal)
bindkey -e

# Ctrl+C / Ctrl+V — clipboard (via wl-clipboard on Wayland)
x-yank () {
    CUTBUFFER=$(wl-paste -n 2>/dev/null)
    zle yank
}
zle -N x-yank
bindkey '^V' x-yank                  # Ctrl+V = paste from clipboard

# Navigation
bindkey '^[[H'   beginning-of-line   # Home
bindkey '^[[F'   end-of-line         # End
bindkey '^[[3~'  delete-char         # Delete
bindkey '^[[1;5C' forward-word       # Ctrl+Right = next word
bindkey '^[[1;5D' backward-word      # Ctrl+Left  = prev word
bindkey '^H'     backward-kill-word  # Ctrl+Backspace = delete word back
bindkey '^[[3;5~' kill-word          # Ctrl+Delete = delete word forward

# History search with ↑/↓ (substring match)
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^P'   history-substring-search-up
bindkey '^N'   history-substring-search-down

# Accept autosuggestion with → or End
bindkey '^[[C' forward-char          # Right arrow (also accepts suggestion char by char)
bindkey '^[f'  forward-word          # Alt+F = accept next word of suggestion

# Ctrl+R = fuzzy history search (fzf)
bindkey '^R' fzf-history-widget

# Ctrl+Z = undo, Ctrl+Y = redo
# bindkey '^Z' undo  # Removed: conflicts with job suspension (Ctrl+Z)
bindkey '^Y' redo

# Ctrl+A / Ctrl+E = beginning/end of line
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line

# ─── Smart Options ──────────────────────────────────────────
setopt AUTO_CD                 # Type dir name to cd into it
setopt AUTO_PUSHD              # Push dirs onto stack automatically
setopt PUSHD_IGNORE_DUPS       # Don't push duplicates
setopt CORRECT                 # Suggest corrections for commands
setopt INTERACTIVE_COMMENTS    # Allow # comments in interactive shell
setopt NO_BEEP                 # Silence the beep

# ─── Aliases ────────────────────────────────────────────────
# File listing (eza)
alias ls='eza --icons --color=auto'
alias ll='eza --icons --color=auto -l'
alias la='eza --icons --color=auto -a'
alias lla='eza --icons --color=auto -la'
alias lt='eza --icons --color=auto -a --tree --level=1'

# Tools
alias grep='grep --color=auto'
alias vim='nvim'
alias lzg='lazygit'
alias lzd='lazydocker'
alias cat='bat --style=auto'

# Fastfetch
alias fastfetchTheme="$HOME/.config/fastfetch/fftheme.sh"
alias fft=fastfetchTheme
alias ff="$HOME/.config/fastfetch/launch.sh"
alias fastfetch='ff'

# Quick navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Safety nets
# ─── Rice toys (colours follow the wallpaper via the terminal palette) ───
alias clock='tty-clock -c -s -B -C 4'          # big centred clock
alias matrix='cmatrix -ab -C blue'             # falling code
alias lava='lavat -c blue -R 2 -k cyan'        # lava lamp
alias pipes='pipes.sh -t 0 -c 4 -c 5 -c 6'     # pipes
alias bonsai='cbonsai -liv'                    # growing bonsai
alias music='rmpc'                             # music player (reads ~/Music)

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# ─── Tool Integrations ──────────────────────────────────────
# Zoxide (smart cd) — use `z` instead of `cd`
eval "$(zoxide init zsh)"

# fzf keybindings and completion
source <(fzf --zsh) 2>/dev/null

# Starship prompt
eval "$(starship init zsh)"

# ─── Startup ────────────────────────────────────────────────
ff

# ─── PATH ────────────────────────────────────────────────────
typeset -U path
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.npm-global/bin:$PATH"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
