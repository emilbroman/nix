local wezterm = require 'wezterm'

local config = wezterm.config_builder()

config.default_prog = { "/run/current-system/sw/bin/zellij", "attach", "--create", "main" }

config.window_decorations = "NONE"
config.enable_tab_bar = false

wezterm.on('update-status', function(window)
  if not window:get_dimensions().is_full_screen then
    window:toggle_fullscreen()
  end
end)

return config
