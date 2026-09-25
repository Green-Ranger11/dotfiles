pragma Singleton
import QtQuick
import Quickshell

Singleton {
    // Catppuccin Mocha, same values as ~/.config/waybar/current-theme.css.
    readonly property color rosewater: "#f5e0dc"
    readonly property color pink: "#f5c2e7"
    readonly property color mauve: "#cba6f7"
    readonly property color red: "#f38ba8"
    readonly property color peach: "#fab387"
    readonly property color yellow: "#f9e2af"
    readonly property color green: "#a6e3a1"
    readonly property color teal: "#94e2d5"
    readonly property color sky: "#89dceb"
    readonly property color sapphire: "#74c7ec"
    readonly property color blue: "#89b4fa"
    readonly property color lavender: "#b4befe"
    readonly property color text: "#cdd6f4"
    readonly property color subtext1: "#bac2de"
    readonly property color subtext0: "#a6adc8"
    readonly property color overlay0: "#6c7086"
    readonly property color surface2: "#585b70"
    readonly property color surface1: "#45475a"
    readonly property color surface0: "#313244"
    readonly property color base: "#1e1e2e"
    readonly property color mantle: "#181825"
    readonly property color crust: "#11111b"

    // Semantic roles, mirroring waybar's current-theme.css.
    readonly property color accent: green
    readonly property color mainBg: crust
    readonly property color mainFg: text
    readonly property color mainBr: green
    readonly property color hoverBg: base

    // Icons all sit on one green ramp: lit when the thing is on, dim when it
    // is off. Only a real alert breaks out of green (warn -> crit).
    readonly property color iconOn: accent
    readonly property color iconMid: Qt.darker(accent, 1.7)
    readonly property color iconDim: Qt.darker(accent, 2.8)
    readonly property color warn: yellow
    readonly property color crit: red

    // Sharp corners, matching decoration.rounding = 1 in appearance.lua.
    readonly property int radius: 1
    // Popups (OSD, notifications, launcher) still draw a border; the bar does not.
    readonly property int borderWidth: 2

    // Docked: flush to the top edge, full width, no border.
    readonly property int barHeight: 40
    readonly property int padding: 10
    readonly property int spacing: 4
    readonly property int groupSpacing: 22
    // Gap popups (notifications, OSD) keep from the screen edge.
    readonly property int marginSide: 12

    // Underline that marks the active tab.
    readonly property int underline: 2

    // One font everywhere. Waybar already uses this; nerd glyphs included.
    readonly property string fontFamily: "CommitMono Nerd Font"
    readonly property int fontSize: 14
    // waybar's dividers.css ran the curve glyphs at 22px, the distro and the
    // active workspace at 20px.
    readonly property int dividerSize: 26
    readonly property int iconSize: 17
    // Inline meter that sits under a value (cpu, memory, battery ...).
    readonly property int meterWidth: 26
    readonly property int meterHeight: 2
    readonly property int fontWeight: Font.Bold
}
