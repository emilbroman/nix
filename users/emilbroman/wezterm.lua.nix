{
  pkgs,
  theme,
}: ''
  local wezterm = require 'wezterm'

  local config = wezterm.config_builder()

  config.default_prog = { "/bin/sh", "-c", "exec ${pkgs.zellij}/bin/zellij attach --create $WEZTERM_PANE" }

  config.font = wezterm.font {
    family = 'Berkeley Mono',
    weight = 'Regular',
  }
  config.enable_tab_bar = false

  config.initial_cols = 150
  config.initial_rows = 50

  -- Enable when released:
  -- config.macos_fullscreen_extend_behind_notch = true
  config.native_macos_fullscreen_mode = false

  wezterm.on('window-resized', function(window)
    local overrides = window:get_config_overrides() or {}
    if window:get_dimensions().is_full_screen then
      overrides.window_decorations = 'NONE | MACOS_FORCE_DISABLE_SHADOW'
      overrides.window_padding = {
        left = 0,
        right = 0,
        top = 33,
        bottom = 0,
      }
    else
      overrides.window_decorations = 'RESIZE'
      overrides.window_padding = {
        left = 20,
        right = 20,
        top = 20,
        bottom = 20,
      }
    end
    window:set_config_overrides(overrides)
  end)

  config.font_size = 13
  config.line_height = 1.1
  config.cell_width = 0.9

  config.window_close_confirmation = 'NeverPrompt'

  config.colors = {
    background = '#${theme.background}',
    foreground = '#${theme.foreground}',
    cursor_fg = '#${theme.cursorForeground}',
    cursor_bg = '#${theme.cursorBackground}',
    ansi = {
      '#${theme.ansi.black}',
      '#${theme.ansi.red}',
      '#${theme.ansi.green}',
      '#${theme.ansi.yellow}',
      '#${theme.ansi.blue}',
      '#${theme.ansi.magenta}',
      '#${theme.ansi.cyan}',
      '#${theme.ansi.white}',
    },
    brights = {
      '#${theme.brights.black}',
      '#${theme.brights.red}',
      '#${theme.brights.green}',
      '#${theme.brights.yellow}',
      '#${theme.brights.blue}',
      '#${theme.brights.magenta}',
      '#${theme.brights.cyan}',
      '#${theme.brights.white}',
    },
  }

  return config
''
