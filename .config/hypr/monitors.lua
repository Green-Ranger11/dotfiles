-- Monitor Configuration
-- See https://wiki.hypr.land/Configuring/Basics/Monitors/

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})

-- Bind by description, not connector name: this panel enumerates as DP-1 or
-- DP-2 depending on the replug. The old `DP-2` rule matched nothing, so the
-- monitor fell through to the catch-all above and ran at 59.97Hz instead of
-- the 99.98Hz it supports.
hl.monitor({
    output   = "desc:Philips Consumer Electronics Company PHL 346B1C 1322131231233",
    mode     = "3440x1440@99.98",
    position = "auto",
    scale    = 1,
})

-- AOC reports 60Hz as its "preferred" mode but supports 144Hz. It also hangs
-- off the NVIDIA HDMI port (laptop eDP and the DP outputs are on the AMD iGPU).
hl.monitor({
    output   = "desc:AOC 27G1G4 0x0000421A",
    mode     = "1920x1080@144",
    position = "auto",
    scale    = 1,
})
