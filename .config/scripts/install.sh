#!/bin/bash
# Dotfiles dependency installer
# Detects OS and installs required packages for tracked configurations

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[+]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[x]${NC} $1"
}

# Cross-platform CLI / TUI tools
CORE_PACKAGES=(
    zsh starship zoxide mcfly fzf jq wget
    git git-lfs
    neovim vim
    tmux yazi btop bottom fastfetch
)

# Hyprland desktop (Linux Wayland session)
LINUX_HYPR_PACKAGES=(
    hyprland hyprpaper hyprpicker hyprpolkitagent
    xdg-desktop-portal-hyprland qt5-wayland qt6-wayland
    # Quickshell (~/.config/quickshell/mocha) is the bar, notifications, lock
    # screen and every picker (apps, emoji, clipboard, network, bluetooth,
    # power, bitwarden) -- it replaced waybar, swaync, rofi, rofi-rbw, hyprlock.
    quickshell
    sddm # login screen; theme in ~/.config/sddm/themes/mocha
    grim slurp swappy wl-clipboard cliphist
    brightnessctl pavucontrol wireplumber
    networkmanager kdeconnect
    xdg-terminal-exec # Terminal=true apps open in kitty (~/.config/xdg-terminals.list)
    rbw # backs the Quickshell Bitwarden picker
    # File manager: Thunar + gvfs (trash, mounts, sftp), tumbler/ffmpegthumbnailer
    # (thumbnails), archive plugin (right-click extract/compress via ark).
    thunar gvfs tumbler ffmpegthumbnailer thunar-archive-plugin
    zathura zathura-pdf-mupdf # default PDF viewer (see mimeapps.list)
)

# KDE bits — kded services (see hypr/autostart.lua) plus Qt app niceties.
LINUX_KDE_PACKAGES=(
    kded kio polkit
    breeze breeze-icons breeze-gtk breeze-cursors
)

# Theming (Catppuccin Mocha across Qt + GTK + Kvantum)
LINUX_THEMING_PACKAGES=(
    kvantum qt5ct qt6ct
    papirus-icon-theme # icon theme set in gtk settings.ini + kdeglobals + gsettings
)

# Fonts (Nerd Fonts + emoji + CJK + symbols)
LINUX_FONT_PACKAGES=(
    ttf-firacode-nerd ttf-jetbrains-mono-nerd
    ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-common
    otf-commit-mono-nerd otf-font-awesome
    noto-fonts noto-fonts-cjk noto-fonts-emoji
    ttf-liberation
)

# AUR-only packages
LINUX_AUR_PACKAGES=(
    # gazelle-tui / bluetuith: right click on the bar's network / bluetooth
    # icons, for what the Quickshell menus skip (enterprise Wi-Fi, passkey
    # pairing). rofimoji: only its emoji CSVs, read by the emoji picker.
    antigen gazelle-tui bluetuith tmux-plugin-manager ttf-joypixels rofimoji
    # asusctl is AUR-only -- NOT in the official repos. It previously sat in
    # LINUX_HYPR_PACKAGES, where pacman aborted that whole transaction on
    # "target not found", so NONE of the Hyprland packages installed -- and
    # `2>/dev/null || true` hid the failure. Keep ROG tooling in this array.
    asusctl # ROG laptop: asusd daemon + led-mode keybinds
)

# macOS Homebrew formulas (cross-platform tools)
BREW_FORMULAS=(
    zsh starship zoxide mcfly fzf jq wget
    gh git git-lfs
    neovim vim
    tmux yazi btop bottom fastfetch
    nvm antigen
)

# macOS Homebrew casks
BREW_CASKS=(
    kitty
    font-fira-code-nerd-font
    font-jetbrains-mono-nerd-font
    font-symbols-only-nerd-font
)

# Yabai stack — needs custom taps
BREW_YABAI=(
    yabai skhd sketchybar borders
)

install_arch() {
    print_status "Detected Arch Linux"

    if command -v yay &> /dev/null; then
        AUR_HELPER="yay"
    elif command -v paru &> /dev/null; then
        AUR_HELPER="paru"
    else
        print_warning "No AUR helper found — install yay or paru to get AUR packages."
        AUR_HELPER=""
    fi

    print_status "Installing core CLI tools..."
    sudo pacman -S --needed --noconfirm "${CORE_PACKAGES[@]}" kitty 2>/dev/null || true

    print_status "Installing Hyprland desktop..."
    sudo pacman -S --needed --noconfirm "${LINUX_HYPR_PACKAGES[@]}" 2>/dev/null || true

    print_status "Installing KDE bits (kded watcher, Breeze, polkit-kde)..."
    sudo pacman -S --needed --noconfirm "${LINUX_KDE_PACKAGES[@]}" 2>/dev/null || true

    print_status "Installing theming (Kvantum + qt5ct/qt6ct)..."
    sudo pacman -S --needed --noconfirm "${LINUX_THEMING_PACKAGES[@]}" 2>/dev/null || true

    print_status "Installing fonts..."
    sudo pacman -S --needed --noconfirm "${LINUX_FONT_PACKAGES[@]}" 2>/dev/null || true

    if [[ -n "$AUR_HELPER" ]]; then
        print_status "Installing AUR packages with $AUR_HELPER..."
        "$AUR_HELPER" -S --needed --noconfirm "${LINUX_AUR_PACKAGES[@]}" 2>/dev/null || true
    else
        print_warning "Skipped AUR packages: ${LINUX_AUR_PACKAGES[*]}"
    fi

    print_status "Arch Linux package installation complete!"
    echo ""
    print_warning "One-time root steps (not run automatically):"
    echo "  Quickshell lock screen PAM service:"
    echo "    sudo cp ~/.config/quickshell/mocha/lock/pam/quickshell-lock /etc/pam.d/quickshell-lock"
    echo "  SDDM login screen with the mocha theme (then reboot):"
    echo "    sudo ~/.config/sddm/themes/mocha/install.sh"
    echo "    sudo systemctl disable plasmalogin 2>/dev/null; sudo systemctl enable sddm"
    echo "  rbw (Bitwarden picker, Super+/). register needs the personal API key"
    echo "  (web vault > Settings > Security > Keys); the pinentry reads the master"
    echo "  password from the login keyring after the first unlock:"
    echo "    rbw config set email <you@example.com> && rbw register && rbw login"
    echo "    rbw config set pinentry ~/.config/scripts/rbw-pinentry-keyring"
}

install_macos() {
    print_status "Detected macOS"

    if ! command -v brew &> /dev/null; then
        print_error "Homebrew not found. Please install it first:"
        echo '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
        exit 1
    fi

    print_status "Installing core formulas..."
    brew install "${BREW_FORMULAS[@]}" 2>/dev/null || true

    print_status "Tapping font cask repo..."
    brew tap homebrew/cask-fonts 2>/dev/null || true

    print_status "Installing casks (kitty + Nerd Fonts)..."
    brew install --cask "${BREW_CASKS[@]}" 2>/dev/null || true

    print_status "Tapping yabai/skhd/sketchybar/borders repos..."
    brew tap koekeishiya/formulae 2>/dev/null || true
    brew tap FelixKratz/formulae 2>/dev/null || true

    print_status "Installing yabai stack..."
    brew install "${BREW_YABAI[@]}" 2>/dev/null || true

    print_warning "Linux-only packages (hyprland, quickshell, sddm, KDE bits) skipped on macOS"
    print_warning "Yabai needs SIP partially disabled for some features — see https://github.com/koekeishiya/yabai/wiki"

    print_status "macOS package installation complete!"
}

install_debian() {
    print_status "Detected Debian/Ubuntu"

    print_status "Updating package lists..."
    sudo apt update

    DEBIAN_CORE=(
        zsh git git-lfs neovim vim kitty tmux btop fzf jq wget
    )

    DEBIAN_LINUX=(
        rofi dunst
        grim slurp wl-clipboard
        brightnessctl playerctl pavucontrol
        network-manager kdeconnect
        kvantum qt5ct qt6ct
        fonts-firacode fonts-noto fonts-noto-cjk fonts-noto-color-emoji
    )

    print_status "Installing available packages with apt..."
    sudo apt install -y "${DEBIAN_CORE[@]}" "${DEBIAN_LINUX[@]}" 2>/dev/null || true

    print_warning "These need manual install on Debian/Ubuntu:"
    echo "  starship: curl -sS https://starship.rs/install.sh | sh"
    echo "  yazi:     cargo install --locked yazi-fm yazi-cli"
    echo "  bottom:   cargo install bottom"
    echo "  zoxide:   curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh"
    echo "  fastfetch: build from source or use a PPA"
    echo "  hyprland: build from source — not in Debian repos"
    echo "  waybar:   may need a backport"

    print_status "Debian/Ubuntu package installation complete!"
}

install_fedora() {
    print_status "Detected Fedora"

    print_status "Installing core packages with dnf..."
    sudo dnf install -y "${CORE_PACKAGES[@]}" 2>/dev/null || true
    sudo dnf install -y "${LINUX_HYPR_PACKAGES[@]}" 2>/dev/null || true
    sudo dnf install -y "${LINUX_KDE_PACKAGES[@]}" "${LINUX_THEMING_PACKAGES[@]}" 2>/dev/null || true

    print_warning "Some Arch package names may differ on Fedora — check failures above."
    print_status "Fedora package installation complete!"
}

# Main installation logic
main() {
    echo "========================================"
    echo "  Dotfiles Dependency Installer"
    echo "========================================"
    echo ""

    if [[ "$OSTYPE" == "darwin"* ]]; then
        install_macos
    elif [[ -f /etc/arch-release ]]; then
        install_arch
    elif [[ -f /etc/debian_version ]]; then
        install_debian
    elif [[ -f /etc/fedora-release ]]; then
        install_fedora
    else
        print_error "Unsupported operating system"
        print_warning "Please install packages manually — see README.md"
        exit 1
    fi

    echo ""
    print_status "Installation complete!"
    echo ""
    echo "Next steps:"
    echo "  1. Set zsh as default shell: chsh -s \$(which zsh)"
    echo "  2. Log out and back in for shell changes to take effect"
    echo "  3. Start a new terminal session"
    echo "  4. herdr (agent multiplexer, config in ~/.config/herdr):"
    echo "       curl -fsSL https://herdr.dev/install.sh | sh"
    echo "       herdr integration install claude"
    echo "  5. Green-folder icon theme (Papirus-Dark-Green, set in kdeglobals/qt*ct/gtk):"
    echo "       ~/.config/scripts/papirus-green.sh"
    echo "       gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark-Green'"
}

main "$@"
