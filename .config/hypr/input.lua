-- Input Configuration
-- See https://wiki.hypr.land/Configuring/Basics/Variables/

hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "caps:escape",
        kb_rules   = "",

        follow_mouse = 1,

        scroll_factor = 2.0, -- mouse wheel multiplier (apps decide base lines)

        touchpad = {
            natural_scroll = false,
            scroll_factor  = 2.0,
        },

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.
    },
})

-- The touchpad exposes a second, useless "Mouse" HID node
-- (ASUF1204:00 2808:0201 Mouse, /dev/input/event4). After an i2c driver
-- rebind it can report left+right as permanently held; libinput then
-- emulates a stuck middle button on it and aquamarine drops every real
-- middle click (seat count 2). Nothing uses this node: keep it off.
hl.device({ name = "asuf1204:00-2808:0201-mouse", enabled = false })
