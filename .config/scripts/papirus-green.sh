#!/bin/sh
# Build ~/.local/share/icons/Papirus-Dark-Green: Papirus-Dark with green
# folders, as user-level symlinks into the installed Papirus theme (the same
# swap papirus-folders does, without editing /usr/share). Re-run after a
# papirus-icon-theme update adds new folder icons.
set -e
P=/usr/share/icons/Papirus
T="$HOME/.local/share/icons/Papirus-Dark-Green"
rm -rf "$T"
for d in "$P"/*/places; do
    out="$T/$(basename "$(dirname "$d")")/places"
    mkdir -p "$out"
    for l in "$d"/*; do
        [ -L "$l" ] || continue
        tgt=$(readlink "$l")
        case "$tgt" in *-blue*) ;; *) continue ;; esac
        g=$(printf %s "$tgt" | sed 's/-blue/-green/g')
        [ -e "$d/$g" ] && ln -s "$d/$g" "$out/$(basename "$l")"
    done
done
sed -e 's/^Name=.*/Name=Papirus-Dark-Green/' \
    -e 's/^Comment=.*/Comment=Papirus-Dark with green folders (user-level symlinks)/' \
    -e 's/^Inherits=.*/Inherits=Papirus-Dark,breeze-dark,hicolor/' \
    "$P-Dark/index.theme" > "$T/index.theme"
