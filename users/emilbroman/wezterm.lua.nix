let
  palette = import ./palette.nix;
in ''
  local wezterm = require 'wezterm'

  local config = wezterm.config_builder()

  -- FIXME
  config.default_prog = { "/Users/emilbroman/.nix-profile/bin/zellij", "attach", "--create" }

  config.font = wezterm.font {
    family = 'Berkeley Mono',
    weight = 'Regular',
  }
  config.window_decorations = "NONE"
  config.enable_tab_bar = false

  wezterm.on('update-status', function(window)
    if not window:get_dimensions().is_full_screen then
      window:toggle_fullscreen()
    end
  end)

  config.font_size = 13
  config.line_height = 1.1
  config.cell_width = 0.9
  config.window_padding = {
    left = 0,
    right = 0,
    top = 33,
    bottom = 0,
  }

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
