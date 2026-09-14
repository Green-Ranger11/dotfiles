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
