<div align="center">

# 〜 dotfiles 〜

**Catppuccin Mocha rice for Arch (Hyprland) & macOS (yabai)**

![Arch](https://img.shields.io/badge/Arch_Linux-1793D1?style=for-the-badge&logo=archlinux&logoColor=white)
![Hyprland](https://img.shields.io/badge/Hyprland-58E1FF?style=for-the-badge&logo=hyprland&logoColor=black)
![macOS](https://img.shields.io/badge/macOS-000000?style=for-the-badge&logo=apple&logoColor=white)
![Catppuccin](https://img.shields.io/badge/theme-Catppuccin_Mocha-cba6f7?style=for-the-badge)

<img src=".github/assets/hero.png" alt="Desktop overview" width="100%"/>

</div>

---

## ✨ What's inside

One repo, two platforms — the same Catppuccin Mocha look on a Linux laptop and a Mac.

| | Linux (Wayland) | macOS |
|---|---|---|
| **WM** | [Hyprland](https://hypr.land) (i3 as X11 fallback) | yabai |
| **Bar** | waybar | sketchybar |
| **Hotkeys** | Hyprland binds | skhd |
| **Launcher** | rofi | rofi themes reused |
| **Notifications** | swaync | — |
| **Lockscreen** | hyprlock / swaylock | — |

**Everywhere:** kitty · tmux · zsh · starship · neovim (LazyVim) · yazi · fzf + zoxide + mcfly · FiraCode Nerd Font

<details>
<summary><b>Full tool list</b></summary>

- **hyprland / i3** — WM (Wayland / X11 fallback)
- **yabai + skhd + sketchybar + borders** — macOS WM stack
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

</details>

## 📸 Gallery

| Terminal workspace | Launcher |
|---|---|
| <img src=".github/assets/terminal.png" width="100%"/> | <img src=".github/assets/rofi.png" width="100%"/> |

| Editor | Lockscreen |
|---|---|
| <img src=".github/assets/nvim.png" width="100%"/> | <img src=".github/assets/hyprlock.png" width="100%"/> |

<div align="center">
<img src=".github/assets/demo.gif" alt="Workflow demo" width="80%"/>
</div>

## 🚀 Install

This is a [bare git repo](https://www.atlassian.com/git/tutorials/dotfiles) — files live at their real `$HOME` paths, no symlink farm.

```bash
git clone --bare https://github.com/Green-Ranger11/dotfiles.git $HOME/.dotfiles
alias config='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
config checkout
config config --local status.showUntrackedFiles no
~/.config/scripts/install.sh
```

If `checkout` complains about existing files, back them up first:

```bash
mkdir -p ~/.dotfiles-backup
config checkout 2>&1 | grep -E "^\s" | awk '{print $1}' | xargs -I{} mv {} ~/.dotfiles-backup/{}
config checkout
```

Packages for Arch / macOS / Debian / Fedora are handled by `~/.config/scripts/install.sh`.

## ⌨️ Keybinds

Keybinds live in [`.config/hypr/conf.d/keybinds.conf`](.config/hypr/conf.d/keybinds.conf) (Linux) and [`.config/skhd`](.config/skhd) (macOS). Highlights: `SUPER+RET` terminal, `SUPER+D` launcher, `SUPER+/` Bitwarden, `SUPER+SHIFT+V` clipboard history.

## 🎨 Theming

Catppuccin Mocha across the board — Hyprland colors are variables in [`.config/hypr/themes/mocha.conf`](.config/hypr/themes/mocha.conf), Qt via Kvantum, GTK 3/4 themed to match. Swap the palette file and everything follows.

---

<div align="center">
<sub>⭐ If something here saved you a config-debugging evening, a star is appreciated.</sub>
</div>
