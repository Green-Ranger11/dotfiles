# Dotfiles

Personal dotfiles managed with a bare git repository.

## What's Included

| Category | Configs |
|----------|---------|
| Shell | zsh, starship, zoxide, mcfly, fzf |
| Editor | neovim (LazyVim) |
| Terminal | kitty, tmux |
| Window Managers | hyprland, i3 |
| Bars & Menus | waybar, rofi, dunst, swaync |
| Screenshots | grim, slurp, swappy, wl-clipboard, cliphist |
| Utilities | hyprpicker, brightnessctl, networkmanager-dmenu |
| Tools | yazi (smart-quit floating mode), btop, fastfetch, bottom |

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
