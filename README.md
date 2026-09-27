# 🏔️ Vijay's Arch Linux Dotfiles

> Personal dotfiles for my Arch Linux (Hyprland) setup on a Lenovo IdeaPad S540.

![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)
![Hyprland](https://img.shields.io/badge/Hyprland-58E1FF?style=for-the-badge&logo=wayland&logoColor=black)
![Neovim](https://img.shields.io/badge/Neovim-57A143?style=for-the-badge&logo=neovim&logoColor=white)
![Zsh](https://img.shields.io/badge/Zsh-F15A24?style=for-the-badge&logo=gnu-bash&logoColor=white)

## 📋 System Overview

| Component | Details |
|---|---|
| **OS** | Arch Linux (Rolling) |
| **Kernel** | Linux 7.2.x |
| **WM** | Hyprland (Wayland) |
| **Shell** | Zsh + Zinit + Starship |
| **Terminal** | Ghostty (primary), Kitty (secondary) |
| **Editor** | Neovim (lazy.nvim + Rose Pine), Zed (vim + Catppuccin), VS Code |
| **Bar** | Waybar |
| **Launcher** | Rofi |
| **Notifications** | SwayNC |
| **File Manager** | Nautilus + Yazi (TUI) |
| **Multiplexer** | Tmux (ThePrimeagen-style) |
| **Display Manager** | SDDM (Astronaut theme) |
| **Boot Splash** | Plymouth (jojo-bizarre theme) |
| **Bootloader** | GRUB (jojo-bizarre graphical theme) |
| **GTK Theme** | adw-gtk3-dark |
| **Icons** | WhiteSur-dark |
| **Cursor** | macOS (Apple cursor) |
| **Input Method** | Fcitx5 (fcitx5-bamboo) |
| **Fonts** | JetBrainsMono Nerd Font, FiraCode Nerd Font, Fira Sans |
| **AUR Helper** | yay |
| **Containers** | Docker + Docker Compose |
| **Databases** | PostgreSQL, MongoDB, Valkey |
| **Languages** | Node.js, Bun, Rust, Python, Go, Lua, Java, Ruby, C/C++ |
| **Hardware** | Lenovo IdeaPad S540-15IWL (Intel + NVIDIA) |

## 🗂️ What's Included

```
dotfiles/
├── zsh/                  # Zsh config (Zinit, aliases, keybindings)
├── tmux/                 # Tmux config (ThePrimeagen-style)
├── nvim/                 # Neovim config (lazy.nvim, LSP, Treesitter)
├── starship/             # Starship prompt config
├── ghostty/              # Ghostty terminal config
├── kitty/                # Kitty terminal config
├── fastfetch/            # Fastfetch config + launch scripts + theme images
│   └── themes/           #   └── Berserk, ChainsawMan, Dandadan, JJK, etc.
├── git/                  # Git config
├── zed/                  # Zed editor settings (vim mode, Catppuccin)
├── vscode/               # VS Code settings + extensions list
├── lazygit/              # Lazygit config (Rose Pine theme, delta diffs)
├── lazydocker/           # Lazydocker config
├── opencode/             # OpenCode AI config
├── gtk-3.0/              # GTK3 theme settings
├── gtk-4.0/              # GTK4 theme settings
├── qt6ct/                # Qt6 theme config (WhiteSur icons)
├── xsettingsd/           # X settings daemon config
├── hypr/                 # Hyprland WM config (Lua-based)
│   ├── conf/             #   └── animations, decorations, keybindings, etc.
│   ├── scripts/          #   └── power, screenshot, gamemode, etc.
│   ├── effects/          #   └── wallpaper effects
│   └── assets/           #   └── lockscreen images
├── jay/                  # Jay/ML4W framework (scripts, settings, themes)
│   ├── scripts/          #   └── wallpaper, autostart, updates, etc.
│   ├── settings/         #   └── waybar, rofi, dock preferences
│   ├── themes/           #   └── glass, modern, transparent
│   ├── wallpapers/       #   └── JoJo wallpapers + default
│   └── listeners/        #   └── GTK theme switcher, low battery
├── quickshell/           # Quickshell Wayland widgets (calendar, power, etc.)
├── matugen/              # Material color generation (auto-theming)
├── rofi/                 # Rofi launcher config
├── waybar/               # Waybar status bar + themes
├── swaync/               # SwayNC notification config + themes
├── wlogout/              # Wlogout power menu + icons + themes
├── nwg-dock-hyprland/    # NWG dock config + themes
├── nwg-displays/         # Display layout configuration
├── nwg-look/             # GTK styling configuration
├── sidepad/              # Sidepad scratchpad utility & configs
├── jay-dotfiles-settings/# Jay settings manager config
├── walker/               # Walker launcher theme
├── waypaper/             # Waypaper wallpaper manager config
├── btop/                 # Btop system monitor config
├── fcitx5/               # Fcitx5 IME input method config
├── bashrc/               # Modular bash configuration scripts
├── boot/                 # 🌟 Custom Boot Themes
│   ├── grub/             #   └── JoJo GRUB theme & installer script
│   └── plymouth/         #   └── JoJo Plymouth splash theme
├── system/               # System templates (sddm.conf, pacman.conf, grub)
├── wallpapers/           # 🖼️ Desktop wallpapers collection
├── scripts/              # Custom scripts (tmux-sessionizer, dev-tools, jay)
├── chromium-flags.conf   # Chromium Wayland flags
├── edge-flags.conf       # Edge Wayland flags
├── .bash_profile         # Bash profile (PATH, cargo env)
├── .zshenv               # Zsh env (Mesa/WebKit GPU hardware flags)
├── .profile              # User profile
├── .npmrc                # npm config
├── mimeapps.list         # Default application associations
├── user-dirs.dirs        # XDG user directories
├── packages.txt          # Explicitly installed pacman packages (172)
├── packages-aur.txt      # AUR packages list (17)
├── install.sh            # 🚀 Automated install script
└── README.md             # This file
```

## 🚀 Quick Install

```bash
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/Projects/dotfiles
cd ~/Projects/dotfiles
chmod +x install.sh
./install.sh
```

### Install Options

The install script supports:
- `./install.sh` — Full interactive install (prompts for each step)
- `./install.sh --packages` — Install packages only (pacman + AUR)
- `./install.sh --dotfiles` — Symlink dotfiles only
- `./install.sh --services` — Enable systemd services & configure SDDM
- `./install.sh --dev` — Setup dev tools (npm globals, Rust, Bun, VS Code extensions)
- `./install.sh --boot` — Install JoJo GRUB & Plymouth boot themes
- `./install.sh --all` — Full unattended install (no prompts)

## 🔑 Key Keybindings

### Neovim
| Key | Action |
|---|---|
| `Space` | Leader key |
| `<leader>pf` | Find files (Telescope) |
| `<C-p>` | Git files |
| `<leader>ps` | Grep search |
| `<leader>a` | Harpoon add |
| `<C-e>` | Harpoon menu |
| `<leader>gg` | LazyGit |
| `<leader>f` | Format file |
| `-` | Oil file manager |

### Tmux
| Key | Action |
|---|---|
| `C-a` | Prefix (instead of C-b) |
| `prefix + \|` | Split horizontal |
| `prefix + -` | Split vertical |
| `prefix + h/j/k/l` | Navigate panes |
| `prefix + g` | LazyGit |
| `prefix + d` | LazyDocker |
| `prefix + b` | Btop |
| `prefix + f` | Tmux sessionizer |

### Zsh
| Key | Action |
|---|---|
| `Ctrl+R` | Fuzzy history search (fzf) |
| `Ctrl+V` | Paste from clipboard |
| `↑/↓` | History substring search |
| `z <dir>` | Zoxide smart cd |

## 📦 Notable CLI Tools

- **eza** — Modern `ls` replacement
- **bat** — `cat` with syntax highlighting
- **fzf** — Fuzzy finder
- **zoxide** — Smart `cd`
- **lazygit** / **lazydocker** — TUI for git/docker
- **btop** — System monitor
- **yazi** — Terminal file manager
- **starship** — Cross-shell prompt
- **fastfetch** — System info (with anime/pokemon themes!)
- **gum** — Interactive shell scripts
- **fd** — Fast `find` alternative
- **ast-grep** — Structural code search

## 🛠️ Development Environment

### Editors
| Editor | Config | Notes |
|---|---|---|
| **Neovim** | `nvim/` | Primary editor — lazy.nvim, Rose Pine, Mason LSP |
| **Zed** | `zed/` | Vim mode, Catppuccin Macchiato, Copilot AI |
| **VS Code** | `vscode/` | Minimal — used for container dev |

### Languages & Runtimes
| Tool | Install Method |
|---|---|
| **Node.js** + **npm** | pacman |
| **Bun** | curl installer |
| **Rust** (rustup, cargo) | pacman + rustup |
| **Python** + pip + virtualenv | pacman |
| **Go** | pacman |
| **Lua** + LuaRocks | pacman |
| **Java** (JRE 21) | pacman |
| **Ruby** | pacman |
| **Clang** / **GCC** | pacman |
| **ARM GCC** (embedded) | pacman |

### npm Globals
- `typescript`, `typescript-language-server`, `eslint`, `prettier`

### Neovim LSP Servers (via Mason)
- `lua_ls`, `pyright`, `ts_ls`, `clangd`, `rust_analyzer`, `gopls`, `jdtls`

### Docker & Databases
- **Docker** + **Docker Compose** (systemd enabled)
- **PostgreSQL** (systemd enabled)
- **MongoDB** (AUR) + **mongosh**
- **Valkey** (Redis-compatible)

## 📝 Notes

- The Hyprland config uses **Lua** (ML4W/Jay framework style)
- Neovim uses ThePrimeagen-style keymaps
- Tmux status bar uses Rose Pine colors
- Lazygit uses Rose Pine theme + delta for diffs
- Fastfetch randomly shows Pokemon pixel art or anime theme images
- GTK uses macOS cursor theme with WhiteSur icons
- Chromium/Edge flags enable native Wayland support
- Qt6 apps themed via qt6ct with WhiteSur icons
- Zed editor runs in vim mode with Catppuccin Macchiato theme

## 📄 License

Feel free to use, modify, and share. No license required.
