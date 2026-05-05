# Dotfiles

Personal dotfiles managed with a bare git repository.

## What's Included

| Category | Configs |
|----------|---------|
| Shell | zsh, starship, zoxide, mcfly, fzf |
| Editor | neovim (LazyVim), vim |
| Terminal | kitty, tmux |
| Window Managers | hyprland, i3 (Linux); yabai (macOS) |
| Bars & Menus | waybar, rofi, dunst, swaync (Linux); sketchybar, skhd, borders (macOS) |
| Lock & Idle | hyprlock, swaylock |
| Theming | Kvantum, qt5ct, qt6ct, gtk-3.0, gtk-4.0 (Catppuccin Mocha) |
| Screenshots | grim, slurp, swappy, wl-clipboard, cliphist |
| Utilities | hyprpicker, brightnessctl, networkmanager-dmenu, bluetui |
| Tools | yazi (smart-quit floating mode), btop, fastfetch, bottom, gazelle-tui |

## Cool Stuff & Shortcuts

This is the cheatsheet for daily use. Modifier conventions:
- **Linux (Hyprland):** `SUPER` is the main mod (the Windows / Cmd key).
- **macOS (yabai + skhd):** `ctrl + alt` is the main mod (mirrors `SUPER`).

### Hyprland — windows, workspaces, launchers

| Shortcut | Action |
|---|---|
| `SUPER + RETURN` | Launch kitty |
| `SUPER + E` | Launch Dolphin (file manager) |
| `SUPER + D` | Rofi app launcher |
| `SUPER + .` | Rofi emoji picker |
| `SUPER + SHIFT + V` | **Floating clipboard picker** (kitty + rofi/fzf, vim keys) |
| `SUPER + SHIFT + B` | **Floating Bluetooth manager** (`bluetui`) |
| `SUPER + SHIFT + N` | **Floating Nostr/social client** (`gazelle-tui`) |
| `SUPER + SHIFT + E` | **Floating yazi** with `EDITOR=nvim` |
| `SUPER + Q` | Close window |
| `SUPER + V` | Toggle floating |
| `SUPER + C` | Eyedropper colour pick to clipboard (`hyprpicker`) |
| `SUPER + B` | Lock screen (`hyprlock`) |
| `SUPER + M` | Exit Hyprland |
| `SUPER + h/j/k/l` or arrows | Move focus (vim keys or arrows) |
| `SUPER + 1..0` | Switch to workspace |
| `SUPER + SHIFT + 1..0` | Move active window to workspace |
| `SUPER + scroll` | Cycle workspaces |
| `SUPER + LMB / RMB drag` | Move / resize window |
| `CTRL + ALT + SUPER + SHIFT + . / ,` | Move workspace to next / prev monitor |

### Hyprland — hardware & function keys

| Shortcut | Action |
|---|---|
| `SUPER + SHIFT + P / O` | Brightness up / down (5%) |
| `SUPER + SHIFT + K` | Cycle Asus keyboard backlight |
| `Fn` brightness/volume keys | wired to `brightnessctl` / `wpctl` |
| `F10` *or* `Fn touchpad` | **Toggle touchpad with notification** (custom script) |
| `Fn Sleep` | `systemctl suspend` |
| `Fn RFKill` | Toggle all radios |
| `CTRL + PrintScr` *or* `CTRL + I` | Region screenshot → swappy → save to Pictures |
| `CTRL + SHIFT + PrintScr` *or* `CTRL + SHIFT + I` | Region screenshot → clipboard |

### macOS — yabai + skhd (mirrors Hyprland intent)

| Shortcut | Action |
|---|---|
| `ctrl + alt + Q` | Close window |
| `ctrl + alt + V` | Toggle float + grid centre |
| `ctrl + alt + h/j/k/l` or arrows | Focus window in direction |
| `ctrl + alt + shift + h/j/k/l` | Swap window in direction |
| `ctrl + alt + 1..0` | Focus space |
| `ctrl + alt + shift + 1..0` | Move window to space and follow |

Layout is BSP with a 25 px window gap, 35 px L/R padding, and a 60 px slot at the top reserved for sketchybar.

### tmux — custom prefix + vim integration

- **Prefix is `C-Space`** (not `C-b`) — single-handed, no clobbering bash readline.
- `M-H` / `M-L` — previous / next window (no prefix needed).
- `<prefix> "` and `<prefix> %` — split panes **in current pane's directory** (overridden from default).
- vi copy mode: `v` start selection, `C-v` rectangle, `y` yank.
- `vim-tmux-navigator` — `C-h/j/k/l` moves seamlessly between tmux panes *and* nvim splits.
- Plugins: `tpm`, `tmux-sensible`, `tmux-yank`, `tmux-battery`, `tmux-cpu`, Catppuccin Mocha theme.
- Status bar at top, `none` background, lavender session indicator.

### yazi — smart-quit floating mode

The signature trick: `Enter` and `o` open the file **and quit yazi if the open succeeded**, so yazi works as a floating "pick a file then disappear" launcher (paired with `SUPER + SHIFT + E`). `S-Enter` / `O` use the interactive opener picker. Implemented via the `smart-quit` plugin.

### Neovim — LazyVim base

- `S-q` — close current buffer (via Snacks).
- `C-h/j/k/l` (n/i/v) — `vim-tmux-navigator` jumps across both vim splits and tmux panes.
- Everything else is stock LazyVim.

### Rofi launchers

The `~/.config/rofi/bin/` scripts each open a themed Catppuccin menu:

| Script | Purpose |
|---|---|
| `launcher` | App launcher (bound to `SUPER + D`) |
| `runner` | Shell command runner |
| `clipboard` | Clipboard history (cliphist) — kitty floating + fzf with vim keys |
| `emoji` | Emoji picker (bound to `SUPER + .`) |
| `network` | NetworkManager picker |
| `bluetooth` | Bluetooth picker |
| `powermenu` | Lock / suspend / reboot / shutdown |

### Shell — zsh + Antigen + extras

- **Bare-repo dotfiles alias:** `config` (or `conf`) → `git --git-dir=$HOME/.dotfiles --work-tree=$HOME`.
- **Quick-edit aliases:** `dotzsh`, `dotgit`, `dotkitty`, `dothy` (Hyprland), `doti3`, `dotyabai`, `dotskhd`, `dotbar` — open the relevant config in nvim.
- `srczsh` — re-source zshrc.
- `vim` is aliased to `nvim`.
- `cd` is `zoxide` (so `cd partial-name` jumps to frecent dirs).
- `mcfly` with vim keybindings (`MCFLY_KEY_SCHEME=vim`) replaces reverse-search.
- `starship` prompt; XDG-clean env (history, cache, state all under `XDG_*`).
- A handful of **internal SSH/SFTP host aliases** (`sshapache`, `sftpcicd`, etc.) for managed servers — not committed in plaintext, populated from `.zshrc`.

### Kitty

- `C-Shift + j / k` — previous / next tab.
- `C-Shift + w` — close tab.
- Font: FiraCode Nerd Font Mono 11 (other Nerd Fonts available: JetBrainsMono, CommitMono).
- Floating instances are summoned from Hyprland with custom `--class` values (`clippicker`, `floating`, `yazi-float`) so window rules style them as centered overlays.

### Theming (Catppuccin Mocha everywhere)

- **Qt:** Kvantum with custom `catppuccin-mocha-lavender` and `catppuccin-mocha-mauve` themes; `qt5ct` / `qt6ct` colour schemes.
- **GTK:** custom `colors.css` + `window_decorations.css` for both GTK 3 and 4.
- **Terminal/editor:** kitty themes, tmux Catppuccin Mocha, gazelle theme, bottom theme.
- **Icons/cursors:** Breeze (paired with KDE bits below).

### KDE bits running under Hyprland

A few KDE services are loaded so Qt apps (Dolphin, Kate, KDE Connect) feel right:

- `kded6` with `[Module-statusnotifierwatcher] autoload=true` — fixes waybar's tray on non-Plasma sessions (see `~/.config/kded6rc`).
- `hyprpolkitagent` — graphical sudo prompt.
- `kbuildsycoca6` — refreshes file associations.

## Required Packages

The repo's `install.sh` handles most of this automatically — these tables are for reference / manual installs.

### Arch Linux

Cross-platform CLI / TUI tools (pacman):

```
zsh starship zoxide mcfly fzf jq wget github-cli git git-lfs \
neovim vim kitty tmux yazi btop bottom fastfetch nvm
```

Hyprland desktop (pacman):

```
hyprland hyprpaper hyprlock hyprpicker hyprpolkitagent \
xdg-desktop-portal-hyprland qt5-wayland qt6-wayland \
waybar rofi dunst swaync swaylock \
grim slurp swappy wl-clipboard cliphist \
brightnessctl playerctl pavucontrol \
networkmanager networkmanager-dmenu kdeconnect bluetui
```

i3 fallback (pacman): `i3-wm i3blocks i3lock`

KDE bits (needed for the kded statusnotifierwatcher fix that makes waybar's tray work):

```
kded kio polkit polkit-kde-agent breeze breeze-icons breeze-gtk breeze-cursors
```

Theming (pacman):

```
kvantum qt5ct qt6ct
```

Fonts (pacman):

```
ttf-firacode-nerd ttf-jetbrains-mono-nerd ttf-nerd-fonts-symbols \
ttf-nerd-fonts-symbols-common otf-commit-mono-nerd otf-font-awesome \
noto-fonts noto-fonts-cjk noto-fonts-emoji ttf-liberation
```

AUR (yay / paru):

```
antigen gazelle-tui tmux-plugin-manager ttf-joypixels rofimoji
```

### macOS (Homebrew)

CLI / TUI tools (brew):

```
zsh starship zoxide mcfly fzf jq wget gh git git-lfs \
neovim vim tmux yazi btop bottom fastfetch nvm antigen
```

Casks:

```
kitty font-fira-code-nerd-font font-jetbrains-mono-nerd-font \
font-symbols-only-nerd-font
```

Yabai stack (Homebrew tap `koekeishiya/formulae` + `FelixKratz/formulae`):

```
yabai skhd sketchybar borders
```

> Yabai requires disabling SIP for some features — see the upstream docs.

## Installation on a New Machine

### 1. Clone the bare repository

```bash
git clone --bare https://github.com/Green-Ranger11/dotfiles.git $HOME/.dotfiles
```

### 2. Define the config alias

```bash
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
```

### 3. Checkout the dotfiles

```bash
config checkout
```

If you get errors about existing files, back them up first:

```bash
mkdir -p ~/.dotfiles-backup
config checkout 2>&1 | grep -E "\s+\." | awk {'print $1'} | xargs -I{} mv {} ~/.dotfiles-backup/{}
config checkout
```

### 4. Hide untracked files

```bash
config config --local status.showUntrackedFiles no
```

### 5. Install dependencies

```bash
~/.config/scripts/install.sh
```

### 6. Make the alias permanent

Add to your shell rc file (already in `.config/zsh/.zshrc`):

```bash
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
```

## Usage

```bash
config status
config add ~/.config/some/file
config commit -m "Add some config"
config push
```

## One-Liner Install

```bash
git clone --bare https://github.com/Green-Ranger11/dotfiles.git $HOME/.dotfiles && \
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME' && \
config checkout 2>/dev/null || (mkdir -p ~/.dotfiles-backup && config checkout 2>&1 | grep -E "^\s" | awk '{print $1}' | xargs -I{} mv {} ~/.dotfiles-backup/{} && config checkout) && \
config config --local status.showUntrackedFiles no && \
~/.config/scripts/install.sh
```
