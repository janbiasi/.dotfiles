local wezterm = require("wezterm")
local mux = wezterm.mux
local act = wezterm.act

local config = {}

-- wezterm.on('update-right-status', function(window, pane)
--   local date = wezterm.strftime '%a, %-d. %B %H:%M '

--   window:set_right_status(wezterm.format {
--     { Text = wezterm.nerdfonts.fa_clock_o .. '  ' .. date },
--   })
-- end)

-- Core behaviour settings
config.window_close_confirmation = "NeverPrompt"
config.initial_cols = 180
config.initial_rows = 48
config.hide_tab_bar_if_only_one_tab = true
config.scrollback_lines = 5000

-- Prevent NVIM issues
-- config.use_dead_keys = false

-- UI settings
config.font = wezterm.font("GeistMono Nerd Font", {})
config.font_size = 13.0
config.line_height = 1.1
config.color_scheme = "Catppuccin Mocha"
config.enable_tab_bar = false

-- Window settings
config.window_background_opacity = 0.93
config.macos_window_background_blur = 15
config.window_decorations = "RESIZE"
config.window_padding = {
  left = 10,
  right = 10,
  top = 10,
  bottom = 0,
}
config.window_frame = {
  inactive_titlebar_bg = "#11111B",
  active_titlebar_bg = "#11111B",
}
config.inactive_pane_hsb = {
  saturation = 0.8,
  brightness = 0.8,
}

-- Hyperlinks
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- Attach to the default Zellij session on startup
--config.default_prog = { "/opt/homebrew/bin/zellij attach --create default" }

return config
