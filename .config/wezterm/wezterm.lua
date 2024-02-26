local wezterm = require("wezterm")
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

-- UI settings
config.font = wezterm.font("GeistMono Nerd Font", {})
config.font_size = 13.0
config.line_height = 1.1
config.color_scheme = "Catppuccin Mocha"

-- Window settings
config.window_background_opacity = 0.93
config.macos_window_background_blur = 15
config.window_decorations = "RESIZE"
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}
config.window_frame = {
  inactive_titlebar_bg = "#11111B",
  active_titlebar_bg = "#11111B",
}

-- Hyperlinks
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- Attach to the default Zellij session on startup
--config.default_prog = { "/opt/homebrew/bin/zellij attach --create default" }

return config
