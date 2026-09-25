#!/bin/sh
# Build ~/.local/share/icons/Breeze-Dark-Green: Breeze Dark (sharp, flat
# icons) with the Catppuccin green accent instead of Breeze blue. Only the
# places/ icons (folders, home, trash, drives) are copied and recoloured;
# everything else is inherited from breeze-dark. User-level, nothing in
# /usr/share is touched. Re-run after a breeze-icons update.
set -e
SRC=/usr/share/icons/breeze-dark
T="$HOME/.local/share/icons/Breeze-Dark-Green"
rm -rf "$T"
for d in "$SRC"/places/*/; do
    size=$(basename "$d")
    mkdir -p "$T/places/$size"
    for f in "$d"*.svg; do
        # -L: breeze-dark places are often symlinks into breeze
        sed 's/#3daee9/#a6e3a1/Ig' "$(readlink -f "$f")" > "$T/places/$size/$(basename "$f")"
    done
done
sed -e 's/^Name=.*/Name=Breeze-Dark-Green/' \
    -e 's/^Comment=.*/Comment=Breeze Dark with green (Catppuccin) folders/' \
    -e 's/^Inherits=.*/Inherits=breeze-dark,hicolor/' \
    "$SRC/index.theme" > "$T/index.theme"
grep -q '^Inherits=' "$T/index.theme" || sed -i 's/^\[Icon Theme\]$/&\nInherits=breeze-dark,hicolor/' "$T/index.theme"
