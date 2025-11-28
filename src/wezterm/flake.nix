{
  outputs = {self}: {
    system-module = {
      homebrew.casks = [
        "wezterm"
      ];
    };

    home-module = {theme}: {pkgs, ...}: {
      programs.wezterm = {
        enable = true;
        extraConfig = ''
          local wezterm = require 'wezterm'

          local config = wezterm.config_builder()

          config.default_prog = { "/bin/sh", "-c", "exec ${pkgs.zellij}/bin/zellij attach --create $WEZTERM_PANE" }

          config.font = wezterm.font {
            family = '${theme.font.mono.name}',
            weight = 'Regular',
          }
          config.font_size = ${builtins.toString theme.font.mono.size}
          config.line_height = ${builtins.toString theme.font.mono.leading}
          config.cell_width = ${builtins.toString theme.font.cellWidth}

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

          config.window_close_confirmation = 'NeverPrompt'

          config.colors = {
            background = '#${theme.wezterm.background}',
            foreground = '#${theme.wezterm.foreground}',
            cursor_fg = '#${theme.wezterm.cursorForeground}',
            cursor_bg = '#${theme.wezterm.cursorBackground}',
            ansi = {
              '#${theme.wezterm.ansi.black}',
              '#${theme.wezterm.ansi.red}',
              '#${theme.wezterm.ansi.green}',
              '#${theme.wezterm.ansi.yellow}',
              '#${theme.wezterm.ansi.blue}',
              '#${theme.wezterm.ansi.magenta}',
              '#${theme.wezterm.ansi.cyan}',
              '#${theme.wezterm.ansi.white}',
            },
            brights = {
              '#${theme.wezterm.brights.black}',
              '#${theme.wezterm.brights.red}',
              '#${theme.wezterm.brights.green}',
              '#${theme.wezterm.brights.yellow}',
              '#${theme.wezterm.brights.blue}',
              '#${theme.wezterm.brights.magenta}',
              '#${theme.wezterm.brights.cyan}',
              '#${theme.wezterm.brights.white}',
            },
          }

          return config
        '';
      };
    };
  };
}
