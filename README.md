<div align="center">

# 〜 dotfiles 〜

**Catppuccin Mocha rice for Arch + Hyprland**

![Arch](https://img.shields.io/badge/Arch_Linux-1793D1?style=for-the-badge&logo=archlinux&logoColor=white)
![Hyprland](https://img.shields.io/badge/Hyprland-58E1FF?style=for-the-badge&logo=hyprland&logoColor=black)
![Catppuccin](https://img.shields.io/badge/theme-Catppuccin_Mocha-cba6f7?style=for-the-badge)

<img src=".github/assets/hero.png" alt="Desktop overview" width="100%"/>

</div>

---

## ✨ What's inside

- **hyprland** — WM (i3 as X11 fallback)
- **waybar / rofi / dunst / swaync** — bar / launcher / notifications
- **rbw + rofi-rbw** — Bitwarden CLI + styled rofi vault picker
- **hyprlock / swaylock** — lockscreen
- **kitty + tmux + zsh + starship** — terminal stack
- **neovim (LazyVim)** — editor
- **yazi** — file manager
- **bluetui** — Bluetooth TUI
- **gazelle-tui** — Nostr client
- **fzf + zoxide + mcfly** — fuzzy find / smart cd / history
- **grim + slurp + swappy + wl-clipboard + cliphist** — screenshots & clipboard
- **Kvantum + qt5/6ct + gtk-3/4** — Qt/GTK Catppuccin theming
- **kded6** — needed for waybar's tray (`autoload=true` in kded6rc)

## 📸 Features

| Launcher | Notification center |
|---|---|
| <img src=".github/assets/rofi.png" width="100%"/> | <img src=".github/assets/swaync.png" width="100%"/> |

| Bluetooth | Network |
|---|---|
| <img src=".github/assets/bluetooth.png" width="100%"/> | <img src=".github/assets/network.png" width="100%"/> |

| File picker | Clipboard history |
|---|---|
| <img src=".github/assets/yazi.png" width="100%"/> | <img src=".github/assets/clipboard.png" width="100%"/> |

| Bitwarden vault | Emoji picker |
|---|---|
| <img src=".github/assets/rbw.png" width="100%"/> | <img src=".github/assets/emoji.png" width="100%"/> |

## 🚀 Install

This is a [bare git repo](https://www.atlassian.com/git/tutorials/dotfiles) — files live at their real `$HOME` paths, no symlink farm. Any existing configs that would conflict are backed up to `~/.dotfiles-backup` first.

```bash
git clone --bare https://github.com/Green-Ranger11/dotfiles.git $HOME/.dotfiles
alias config='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'

# back up conflicting files, then check out
mkdir -p ~/.dotfiles-backup
config checkout 2>&1 | grep -E "^\s" | awk '{print $1}' | xargs -I{} mv {} ~/.dotfiles-backup/{}
config checkout

config config --local status.showUntrackedFiles no
~/.config/scripts/install.sh
```

Packages are handled by `~/.config/scripts/install.sh`.
