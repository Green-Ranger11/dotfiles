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

# Core packages (cross-platform)
CORE_PACKAGES=(
    zsh
    starship
    git
    neovim
    kitty
    tmux
    yazi
    btop
    fastfetch
    bottom
)

# Linux-only packages (window managers, bars, etc.)
LINUX_PACKAGES=(
    hyprland
    hyprpaper
    hyprlock
    waybar
    rofi
    dunst
    i3-wm
    i3blocks
)

install_arch() {
    print_status "Detected Arch Linux"

    # Check if yay is available for AUR packages
    if command -v yay &> /dev/null; then
        AUR_HELPER="yay"
    elif command -v paru &> /dev/null; then
        AUR_HELPER="paru"
    else
        print_warning "No AUR helper found. Some packages may need manual installation."
        AUR_HELPER=""
    fi

    print_status "Installing core packages with pacman..."
    sudo pacman -S --needed --noconfirm "${CORE_PACKAGES[@]}" 2>/dev/null || true

    print_status "Installing Linux desktop packages..."
    sudo pacman -S --needed --noconfirm "${LINUX_PACKAGES[@]}" 2>/dev/null || true

    # AUR packages if helper available
    if [[ -n "$AUR_HELPER" ]]; then
        print_status "Checking for AUR packages..."
        # Add any AUR-specific packages here if needed
    fi

    print_status "Arch Linux package installation complete!"
}

install_macos() {
    print_status "Detected macOS"

    # Check for Homebrew
    if ! command -v brew &> /dev/null; then
        print_error "Homebrew not found. Please install it first:"
        echo '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
        exit 1
    fi

    print_status "Installing packages with Homebrew..."
    brew install "${CORE_PACKAGES[@]}" 2>/dev/null || true

    # Install casks for GUI applications
    print_status "Installing cask applications..."
    brew install --cask kitty 2>/dev/null || true

    print_warning "Linux-only packages (hyprland, waybar, rofi, dunst, i3) skipped on macOS"

    print_status "macOS package installation complete!"
}

install_debian() {
    print_status "Detected Debian/Ubuntu"

    print_status "Updating package lists..."
    sudo apt update

    # Map package names for Debian/Ubuntu (some differ)
    DEBIAN_CORE=(
        zsh
        git
        neovim
        kitty
        tmux
        btop
    )

    DEBIAN_LINUX=(
        rofi
        dunst
        i3
        i3blocks
    )

    print_status "Installing available packages with apt..."
    sudo apt install -y "${DEBIAN_CORE[@]}" "${DEBIAN_LINUX[@]}" 2>/dev/null || true

    print_warning "Some packages (starship, yazi, fastfetch, bottom, hyprland, waybar) may need manual installation on Debian/Ubuntu"
    echo "  starship: curl -sS https://starship.rs/install.sh | sh"
    echo "  yazi: cargo install yazi-fm"
    echo "  bottom: cargo install bottom"

    print_status "Debian/Ubuntu package installation complete!"
}

install_fedora() {
    print_status "Detected Fedora"

    print_status "Installing packages with dnf..."
    sudo dnf install -y "${CORE_PACKAGES[@]}" 2>/dev/null || true
    sudo dnf install -y "${LINUX_PACKAGES[@]}" 2>/dev/null || true

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
        print_warning "Please install packages manually:"
        echo "  Core: ${CORE_PACKAGES[*]}"
        echo "  Linux: ${LINUX_PACKAGES[*]}"
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
