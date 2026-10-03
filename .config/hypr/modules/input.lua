hl.config({
  input = {
    kb_layout     = "ch",
    kb_variant    = "de_nodeadkeys",
    kb_model      = "pc105",
    kb_options    = "terminate:ctrl_alt_bksp",
    kb_rules      = "",

    follow_mouse  = 1,

    sensitivity   = 0.15,
    accel_profile = "linear",

    repeat_delay  = 250, -- default is 600
    repeat_rate   = 40,  -- default is 50

    touchpad      = {
      natural_scroll = false,
      scroll_factor = 0.5,
      disable_while_typing = true
    },

  },
})

-- Chromium browsers and their installed PWAs use browser-specific class prefixes.
hl.window_rule({
  name = "chromium-scroll-speed-override",
  match = {
    class =
    "^(brave.*|chromium.*|chrome.*|google-chrome.*|microsoft-edge.*|msedge.*|vivaldi.*|opera.*|chatgpt|com.t3tools.T3Code|Paseo|md.obsidian.Obsidian|discord)$"
  },
  scroll_touchpad = 0.15
})

-- hl.gesture({
--   fingers = 3,
--   direction = "horizontal",
--   action = "workspace"
-- })

-- Example per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
-- hl.device({
--   name        = "epic-mouse-v1",
--   sensitivity = -0.5,
-- })
