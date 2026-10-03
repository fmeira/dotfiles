-- Monitor wiki https://wiki.hypr.land/Configuring/Basics/Monitors/
-- Soft fallbacks per location. kanshi (~/.config/kanshi/config) owns hotplug
-- switching and overrides these when it runs. Unused desc: lines are ignored.

-- Home left / right Dells above laptop
hl.monitor({
    output    = "desc:Dell Inc. DELL U2421E DH3QS83",
    mode      = "1920x1200@59.95",
    position  = "0x0",
    scale     = "1",
})

hl.monitor({
    output    = "desc:Dell Inc. DELL U2421E 8LNC5H3",
    mode      = "1920x1200@59.95",
    position  = "1920x0",
    scale     = "1",
})

-- Work: Lenovo P40w-20 ultrawide above laptop
hl.monitor({
    output    = "desc:Lenovo Group Limited P40w-20 V90E1NK8",
    mode      = "5120x2160@60",
    position  = "0x0",
    scale     = "1",
})

-- Laptop position is set by: hypr-place home|work
--   work: 1600x2160 centered under the Lenovo
--   home: 960x1200  centered under the two Dells
hl.monitor({
    output    = "eDP-1",
    mode      = "preferred",
    position  = "960x1200",
    scale     = "2",
})

-- Unknown outputs
hl.monitor({
    output    = "",
    mode      = "preferred",
    position  = "auto",
    scale     = "auto",
})
