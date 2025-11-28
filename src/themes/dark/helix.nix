{self}: {
  "ui.window" = self.hexpalette.gray."250";
  "ui.background" = self.hexpalette.gray."250";

  "ui.text" = self.hexpalette.gray."150";
  "ui.selection" = {bg = self.hexpalette.gray."300";};

  "ui.linenr" = self.hexpalette.gray."300";
  "ui.linenr.selected" = self.hexpalette.gray."250";
  "ui.cursor.primary" = {bg = self.hexpalette.gray."150";};
  "ui.popup" = {
    bg = self.hexpalette.gray."300";
    fg = self.hexpalette.gray."150";
  };
  "ui.menu" = {
    bg = self.hexpalette.gray."300";
    fg = self.hexpalette.gray."150";
  };
  "ui.menu.selected" = {bg = self.hexpalette.gray."250";};
  "ui.help" = {
    bg = self.hexpalette.gray."300";
    fg = self.hexpalette.gray."150";
  };

  "diff.plus.gutter" = {fg = self.hexpalette.green."300";};
  "diff.minus.gutter" = {fg = self.hexpalette.red."300";};
  "diff.delta.gutter" = {fg = self.hexpalette.orange."300";};

  "ui.statusline" = {
    bg = self.hexpalette.gray."200";
    fg = self.hexpalette.gray."300";
  };
  "ui.statusline.inactive" = {
    bg = self.hexpalette.gray."300";
    fg = self.hexpalette.gray."200";
  };

  "ui.virtual.ruler" = self.hexpalette.gray."300";

  "special" = self.hexpalette.orange."300";
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
    fg = self.hexpalette.blue."350";
    modifiers = ["bold"];
  };

  "type" = self.hexpalette.red."300";
  "constructor" = self.hexpalette.red."250";

  "variable.builtin" = {
    fg = self.hexpalette.blue."250";
    modifiers = ["bold"];
  };
  "variable" = {fg = self.hexpalette.orange."200";};

  "string" = self.hexpalette.green."200";
  "string.special.symbol" = self.hexpalette.blue."200";

  "function" = self.hexpalette.blue."200";

  "comment" = {
    bg = self.hexpalette.gray."300";
    fg = self.hexpalette.gray."100";
    modifiers = ["italic"];
  };

  "punctuation" = self.hexpalette.gray."250";
  "operator" = self.hexpalette.gray."200";
  "namespace" = self.hexpalette.magenta."100";
  "constant" = self.hexpalette.yellow."200";
  "label" = self.hexpalette.blue."250";
}
