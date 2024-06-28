let
  themeName = "emil";
  palette = builtins.mapAttrs (_: color: builtins.mapAttrs (_: hex: "#${hex}") color) (import ./palette.nix);
in {
  settings = {
    theme = themeName;

    editor.cursor-shape = {
      insert = "bar";
      normal = "block";
      select = "underline";
    };
    
    editor.file-picker = {
      hidden = false;
    };

    editor.true-color = true;
  };

  languages.language = [
    {
      name = "markdown";
      auto-format = true;
      formatter.command = "yarn";
      formatter.args = ["prettier" "--parser" "markdown"];
    }
  ];

  themes.${themeName} = {
    "ui.background" = palette.gray."350";
    "ui.text" = palette.gray."150";
    "ui.selection" = { bg = palette.gray."300"; };
    "ui.window" = { bg = palette.gray."300"; fg = palette.gray."150"; };

    "ui.linenr" = palette.gray."300";
    "ui.linenr.selected" = palette.gray."250";
    "ui.cursor.primary" = { bg = palette.gray."150"; };
    "ui.popup" = { bg = palette.gray."300"; fg = palette.gray."150"; };
    "ui.menu" = { bg = palette.gray."300"; fg = palette.gray."150"; };
    "ui.menu.selected" = { bg = palette.gray."250"; };
    "ui.help" = { bg = palette.gray."300"; fg = palette.gray."150"; };

    "ui.statusline" = { bg = palette.gray."150"; fg = palette.gray."350"; };
    "ui.statusline.inactive" = { bg = palette.gray."350"; fg = palette.gray."150"; };

    "ui.virtual.ruler" = palette.gray."300";

    "special" = palette.orange."300";
    "error" = palette.red."400";
    "diagnostic.error" = { fg = palette.red."400"; underline = { color = palette.red."400"; style = "curl"; }; };
    "warning" = palette.yellow."400";
    "diagnostic.warning" = { underline = { color = palette.yellow."400"; style = "dashed"; }; };
    "hint" = palette.blue."400";
    "diagnostic.hint" = { underline = { color = palette.blue."400"; style = "dot"; }; };

    # Syntax highlighting

    "keyword" = { fg = palette.blue."350"; modifiers = ["bold"]; };

    "variable.builtin" = { fg = palette.blue."250"; modifiers = ["bold"]; };
    "variable.other" = { fg = palette.orange."200"; };

    "type" = palette.red."300";
    "constructor" = palette.red."200";

    "string" = palette.green."200";

    "function" = palette.blue."200";

    "comment" = { bg = palette.gray."300"; fg = palette.gray."100"; modifiers = ["italic"]; };

    "punctuation" = palette.gray."250";
    "operator" = palette.gray."200";
    "namespace" = palette.magenta."100";
    "constant" = palette.yellow."200";
    "label" = palette.blue."250";
  };
}
