-- Keep the external display centered above the laptop at either desk.
-- Fallback for any output not named below, so a display at a new desk lands
-- above the laptop right away instead of Hyprland's default of beside it at
-- scale 1. Declared first so the named rules below still win for their outputs.
hl.monitor({ output = "", mode = "preferred", position = "auto-center-up", scale = "auto" })
hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x0", scale = 2 })
hl.monitor({ output = "DP-1", mode = "preferred", position = "auto-center-up", scale = 1.25 })

-- Smooth X11 text when fractional scaling enlarges it.
hl.config({
  xwayland = {
    use_nearest_neighbor = false,
  },
})
