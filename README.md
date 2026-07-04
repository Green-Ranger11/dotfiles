# Dotfiles

Bare git repo. Alias: `config` → `git --git-dir=$HOME/.dotfiles --work-tree=$HOME`.

## Tools

- **hyprland / i3** — WM (Wayland / X11 fallback)
- **yabai + skhd + sketchybar + borders** — macOS WM stack
- **waybar / rofi / dunst / swaync** — bar / launcher / notifications
- **rbw + rofi-rbw** — Bitwarden CLI + styled rofi vault picker (`SUPER + /`)
- **hyprlock / swaylock** — lockscreen
- **kitty + tmux + zsh + starship** — terminal stack
- **neovim (LazyVim)** — editor
- **yazi** — file manager
- **bluetui** — Bluetooth
- **gazelle-tui** — Nostr
- **fzf + zoxide + mcfly** — fuzzy / cd / history
- **grim + slurp + swappy + wl-clipboard + cliphist** — screenshots & clipboard
- **Kvantum + qt5/6ct + gtk-3/4** — Catppuccin Mocha theming
- **kded6** — needed for waybar's tray (`autoload=true` in kded6rc)

## Setup on a new machine

```bash
git clone --bare https://github.com/Green-Ranger11/dotfiles.git $HOME/.dotfiles
alias config='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
config checkout
config config --local status.showUntrackedFiles no
~/.config/scripts/install.sh
```

If `checkout` complains about existing files, back them up:

```bash
mkdir -p ~/.dotfiles-backup
config checkout 2>&1 | grep -E "^\s" | awk '{print $1}' | xargs -I{} mv {} ~/.dotfiles-backup/{}
config checkout
```

Package list lives in `~/.config/scripts/install.sh` (Arch / macOS / Debian / Fedora).
