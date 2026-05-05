# Dotfiles

Personal dotfiles managed with a bare git repository.

## What I Use Each Tool For

- **hyprland** — Wayland window manager (Linux daily driver)
- **i3** — X11 fallback window manager
- **yabai + skhd + sketchybar + borders** — window manager + hotkeys + bar on macOS
- **waybar** — top bar
- **rofi** — app launcher, clipboard picker, emoji, power menu
- **dunst / swaync** — desktop notifications
- **hyprlock / swaylock** — screen locking
- **kitty** — terminal
- **tmux** — terminal multiplexer
- **zsh + starship** — shell + prompt
- **neovim (LazyVim)** — main editor; **vim** as fallback
- **yazi** — file manager (floating mode)
- **bluetui** — Bluetooth manager
- **gazelle-tui** — Nostr client
- **btop / bottom / fastfetch** — system monitors / fetch
- **fzf + zoxide + mcfly** — fuzzy find, smart `cd`, history search
- **grim + slurp + swappy** — screenshot grab/select/annotate
- **wl-clipboard + cliphist** — clipboard + history
- **brightnessctl, hyprpicker, networkmanager-dmenu** — brightness, colour pick, network picker
- **Kvantum / qt5ct / qt6ct / gtk-3.0 / gtk-4.0** — Catppuccin Mocha theming across Qt and GTK
- **kded6** — KDE daemon (loads the `statusnotifierwatcher` module so waybar's tray works)

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
