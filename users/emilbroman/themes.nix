let
  palette = import ./palette.nix;
  hexpalette = builtins.mapAttrs (_: color: builtins.mapAttrs (_: hex: "#${hex}") color) palette;
  fix = f: let result = f result; in result;
in
  fix (self: {
    current = self.dark;

    dark = let
      backdrop = palette.gray."350";
    in {
      wezterm = {
        background = backdrop;
        foreground = palette.gray."150";
        cursorForeground = palette.gray."350";
        cursorBackground = palette.gray."150";
        ansi = {
          black = palette.gray."300";
          red = palette.red."300";
          green = palette.green."250";
          yellow = palette.yellow."250";
          blue = palette.blue."250";
          magenta = palette.magenta."250";
          cyan = palette.cyan."250";
          white = palette.gray."150";
        };
        brights = {
          black = palette.gray."250";
          red = palette.red."150";
          green = palette.green."150";
          yellow = palette.yellow."150";
          blue = palette.blue."150";
          magenta = palette.magenta."150";
          cyan = palette.cyan."150";
          white = palette.gray."100";
        };
      };

      zellij = {
        fg = palette.gray."250";
        bg = backdrop;
        black = palette.gray."400";
        red = palette.red."400";
        green = palette.green."350";
        yellow = palette.yellow."350";
        blue = palette.blue."350";
        magenta = palette.magenta."350";
        cyan = palette.cyan."350";
        white = palette.gray."250";
        orange = palette.orange."350";

        clock = {
          foreground = palette.gray."250";
        };

        pill = {
          inactive = {
            background = palette.gray."300";
            foreground = palette.gray."200";
          };
          active = {
            background = palette.gray."200";
            foreground = palette.gray."300";
          };
        };
      };

      fish = {
        muted = palette.gray."250";

        prompt = {
          errorStatus = {
            background = palette.red."350";
            foreground = palette.red."100";
          };
          shellDepth = {
            background = palette.blue."100";
            foreground = palette.blue."350";
          };
        };

        variables = {
          fish_color_autosuggestion = palette.gray."250";
          fish_color_cancel = "-r";
          fish_color_command = "${palette.yellow."350"} --bold";
          fish_color_comment = "${palette.gray."250"} --italics";
          fish_color_cwd = palette.orange."250";
          fish_color_cwd_root = palette.orange."350";
          fish_color_end = palette.gray."250";
          fish_color_error = palette.red."350";
          fish_color_escape = palette.orange."250";
          fish_color_history_current = "normal";
          fish_color_host = "normal";
          fish_color_host_remote = "normal";
          fish_color_match = palette.gray."300";
          fish_color_normal = palette.gray."150";
          fish_color_operator = palette.magenta."200";
          fish_color_param = palette.yellow."200";
          fish_color_quote = palette.green."200";
          fish_color_redirection = "${palette.magenta."100"} --italics";
          fish_color_search_match = "--background=${palette.gray."300"}";
          fish_color_selection = "--background=${palette.gray."300"}";
          fish_color_status = "${palette.yellow."350"} --underline";
          fish_color_user = palette.orange."350";
          fish_color_valid_path = "${palette.yellow."200"} --underline";
        };
      };

      helix = {
        "ui.window" = hexpalette.gray."250";
        "ui.background" = hexpalette.gray."250";

        "ui.text" = hexpalette.gray."150";
        "ui.selection" = {bg = hexpalette.gray."300";};

        "ui.linenr" = hexpalette.gray."300";
        "ui.linenr.selected" = hexpalette.gray."250";
        "ui.cursor.primary" = {bg = hexpalette.gray."150";};
        "ui.popup" = {
          bg = hexpalette.gray."300";
          fg = hexpalette.gray."150";
        };
        "ui.menu" = {
          bg = hexpalette.gray."300";
          fg = hexpalette.gray."150";
        };
        "ui.menu.selected" = {bg = hexpalette.gray."250";};
        "ui.help" = {
          bg = hexpalette.gray."300";
          fg = hexpalette.gray."150";
        };

        "diff.plus.gutter" = {fg = hexpalette.green."300";};
        "diff.minus.gutter" = {fg = hexpalette.red."300";};
        "diff.delta.gutter" = {fg = hexpalette.orange."300";};

        "ui.statusline" = {
          bg = hexpalette.gray."200";
          fg = hexpalette.gray."300";
        };
        "ui.statusline.inactive" = {
          bg = hexpalette.gray."300";
          fg = hexpalette.gray."200";
        };

        "ui.virtual.ruler" = hexpalette.gray."300";

        "special" = hexpalette.orange."300";
        "error" = hexpalette.red."400";
        "diagnostic.error" = {
          fg = hexpalette.red."400";
          underline = {
            color = hexpalette.red."400";
            style = "curl";
          };
        };
        "warning" = hexpalette.yellow."400";
        "diagnostic.warning" = {
          underline = {
            color = hexpalette.yellow."400";
            style = "dashed";
          };
        };
        "hint" = hexpalette.blue."400";
        "diagnostic.hint" = {
          underline = {
            color = hexpalette.blue."400";
            style = "dashed";
          };
        };

        "diagnostic.unnecessary" = {
          fg = hexpalette.gray."250";
          modifiers = ["italic"];
          underline = {
            color = hexpalette.blue."400";
            style = "dashed";
          };
        };

        "diagnostic.deprecated" = {
          modifiers = ["crossed_out"];
        };

        # Syntax highlighting

        "keyword" = {
          fg = hexpalette.blue."350";
          modifiers = ["bold"];
        };

        "type" = hexpalette.red."300";
        "constructor" = hexpalette.red."250";

        "variable.builtin" = {
          fg = hexpalette.blue."250";
          modifiers = ["bold"];
        };
        "variable" = {fg = hexpalette.orange."200";};

        "string" = hexpalette.green."200";
        "string.special.symbol" = hexpalette.blue."200";

        "function" = hexpalette.blue."200";

        "comment" = {
          bg = hexpalette.gray."300";
          fg = hexpalette.gray."100";
          modifiers = ["italic"];
        };

        "punctuation" = hexpalette.gray."250";
        "operator" = hexpalette.gray."200";
        "namespace" = hexpalette.magenta."100";
        "constant" = hexpalette.yellow."200";
        "label" = hexpalette.blue."250";
      };
    };
  })
