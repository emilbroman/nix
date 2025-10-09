let
  palette = import ./palette.nix;
in
  {pkgs}: ''
    local wezterm = require 'wezterm'

    local config = wezterm.config_builder()

    config.default_prog = { "${pkgs.zellij}/bin/zellij", "attach", "--create" }

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
        overrides.window_background_opacity = 1
        overrides.macos_window_background_blur = 0
      else
        overrides.window_decorations = 'RESIZE'
        overrides.window_padding = {
          left = 20,
          right = 20,
          top = 20,
          bottom = 20,
        }
        overrides.window_background_opacity = 0.98
        overrides.macos_window_background_blur = 50
      end
      window:set_config_overrides(overrides)
    end)

    config.font_size = 13
    config.line_height = 1.1
    config.cell_width = 0.9

    config.window_close_confirmation = 'NeverPrompt'

    config.colors = {
      background = '#${palette.gray."350"}',
      foreground = '#${palette.gray."150"}',
      cursor_fg = '#${palette.gray."350"}',
      cursor_bg = '#${palette.gray."150"}',
      ansi = {
        '#${palette.gray."300"}',
        '#${palette.red."300"}',
        '#${palette.green."250"}',
        '#${palette.yellow."250"}',
        '#${palette.blue."250"}',
        '#${palette.magenta."250"}',
        '#${palette.cyan."250"}',
        '#${palette.gray."150"}',
      },
      brights = {
        '#${palette.gray."250"}',
        '#${palette.red."150"}',
        '#${palette.green."150"}',
        '#${palette.yellow."150"}',
        '#${palette.blue."150"}',
        '#${palette.magenta."150"}',
        '#${palette.cyan."150"}',
        '#${palette.gray."100"}',
      },
    }

    return config
  ''
