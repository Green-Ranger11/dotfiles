#!/bin/sh
# Install the mocha SDDM theme and set it as current. Run with sudo.
# The greeter can't read ~ (0700), so everything is copied to /usr/share.
set -e
dir=$(dirname "$(readlink -f "$0")")
home=$(readlink -f "$dir/../../../..")
install -d /usr/share/sddm/themes/mocha /etc/sddm.conf.d
install -m644 "$dir"/*.qml "$dir"/qmldir "$dir"/metadata.desktop "$dir"/theme.conf /usr/share/sddm/themes/mocha/
# Same wallpaper as the lock screen, from the dotfiles repo.
install -m644 "$home/.github/assets/ml6.jpeg" /usr/share/sddm/themes/mocha/background.jpeg
printf '[Theme]\nCurrent=mocha\n' > /etc/sddm.conf.d/theme.conf
