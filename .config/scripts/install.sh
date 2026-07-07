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
    hyprland hyprpaper hyprlock hyprpicker hyprpolkitagent
    xdg-desktop-portal-hyprland qt5-wayland qt6-wayland
    waybar rofi dunst swaync swaylock
    grim slurp swappy wl-clipboard cliphist
    brightnessctl playerctl pavucontrol wireplumber
    networkmanager kdeconnect bluetui
    rbw rofi-rbw dolphin
    asusctl # ROG laptop keybinds (led-mode, rog-control-center)
)

# i3 fallback
LINUX_I3_PACKAGES=(
    i3-wm i3blocks i3lock
)

# KDE bits — needed for the kded statusnotifierwatcher fix that makes
# waybar's tray work on non-Plasma sessions, plus Qt app niceties.
LINUX_KDE_PACKAGES=(
    kded kio polkit polkit-kde-agent
    breeze breeze-icons breeze-gtk breeze-cursors
)

# Theming (Catppuccin Mocha across Qt + GTK + Kvantum)
LINUX_THEMING_PACKAGES=(
    kvantum qt5ct qt6ct
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
    antigen gazelle-tui tmux-plugin-manager ttf-joypixels rofimoji
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

    print_status "Installing i3 fallback..."
    sudo pacman -S --needed --noconfirm "${LINUX_I3_PACKAGES[@]}" 2>/dev/null || true

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
    print_warning "Reminder: enable kded statusnotifierwatcher autoload (already in ~/.config/kded6rc):"
    echo "  [Module-statusnotifierwatcher]"
    echo "  autoload=true"
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

    print_warning "Linux-only packages (hyprland, waybar, rofi, dunst, i3, KDE bits) skipped on macOS"
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
        rofi dunst i3 i3blocks i3lock
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
    sudo dnf install -y "${LINUX_HYPR_PACKAGES[@]}" "${LINUX_I3_PACKAGES[@]}" 2>/dev/null || true
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
}

main "$@"
