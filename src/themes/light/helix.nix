{self}: {
  "ui.window" = {fg = self.hexpalette.gray."250";};
  "ui.background" = {fg = self.hexpalette.gray."200"; bg = self.hexpalette.gray."100";};
  "ui.background.separator" = {fg = self.hexpalette.gray."200";};

  "ui.text" = self.hexpalette.gray."350";
  "ui.selection" = {bg = self.hexpalette.gray."150";};

  "ui.linenr" = self.hexpalette.gray."200";
  "ui.linenr.selected" = self.hexpalette.gray."250";
  "ui.cursor.primary" = {bg = self.hexpalette.gray."350";};
  "ui.popup" = {
    bg = self.hexpalette.gray."150";
    fg = self.hexpalette.gray."350";
  };
  "ui.menu" = {
    bg = self.hexpalette.gray."150";
    fg = self.hexpalette.gray."350";
  };
  "ui.menu.selected" = {bg = self.hexpalette.gray."200";};
  "ui.help" = {
    bg = self.hexpalette.gray."150";
    fg = self.hexpalette.gray."350";
  };

  "diff.plus.gutter" = {fg = self.hexpalette.green."400";};
  "diff.minus.gutter" = {fg = self.hexpalette.red."400";};
  "diff.delta.gutter" = {fg = self.hexpalette.orange."400";};

  "ui.statusline" = {
    bg = self.hexpalette.gray."150";
    fg = self.hexpalette.gray."350";
  };
  "ui.statusline.inactive" = {
    bg = self.hexpalette.gray."150";
    fg = self.hexpalette.gray."250";
  };

  "ui.virtual.ruler" = self.hexpalette.gray."150";

  "special" = self.hexpalette.orange."400";
  "error" = self.hexpalette.red."400";
  "diagnostic.error" = {
    fg = self.hexpalette.red."400";
    underline = {
      color = self.hexpalette.red."400";
      style = "curl";
    };
  };
  "warning" = self.hexpalette.yellow."400";
  "diagnostic.warning" = {
    underline = {
      color = self.hexpalette.yellow."400";
      style = "dashed";
    };
  };
  "hint" = self.hexpalette.blue."400";
  "diagnostic.hint" = {
    underline = {
      color = self.hexpalette.blue."400";
      style = "dashed";
    };
  };

  "diagnostic.unnecessary" = {
    fg = self.hexpalette.gray."250";
    modifiers = ["italic"];
    underline = {
      color = self.hexpalette.blue."400";
      style = "dashed";
    };
  };

  "diagnostic.deprecated" = {
    modifiers = ["crossed_out"];
  };

  # Syntax highlighting

  "keyword" = {
    fg = self.hexpalette.blue."400";
    modifiers = ["bold"];
  };

  "type" = self.hexpalette.red."400";
  "constructor" = self.hexpalette.red."350";

  "variable.builtin" = {
    fg = self.hexpalette.blue."350";
    modifiers = ["bold"];
  };
  "variable" = {fg = self.hexpalette.orange."400";};

  "string" = self.hexpalette.green."400";
  "string.special.symbol" = self.hexpalette.blue."350";

  "function" = self.hexpalette.blue."350";

  "comment" = {
    bg = self.hexpalette.gray."150";
    fg = self.hexpalette.gray."250";
    modifiers = ["italic"];
  };

  "punctuation" = self.hexpalette.gray."250";
  "operator" = self.hexpalette.gray."300";
  "namespace" = self.hexpalette.magenta."400";
  "constant" = self.hexpalette.yellow."400";
  "label" = self.hexpalette.blue."400";
}
