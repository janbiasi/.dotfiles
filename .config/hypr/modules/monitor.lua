-- Keep the external display centered above the laptop at either desk.
hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x0", scale = 2 })
hl.monitor({ output = "DP-1", mode = "preferred", position = "auto-center-up", scale = 1.25 })
