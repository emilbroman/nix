let
  themeName = "emil";
  palette = builtins.mapAttrs (_: color: builtins.mapAttrs (_: hex: "#${hex}") color) (import ./palette.nix);
in {
  programs.helix = {
    enable = true;

    defaultEditor = true;

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

      editor.soft-wrap.wrap-at-text-width = true;
      editor.soft-wrap.enable = false;
      keys.normal.space.W = ":toggle soft-wrap.enable";
    };

    languages.language-server.biome = {
      command = "biome";
      args = ["lsp-proxy"];
    };

    languages.language-server.gpt = {
      command = "deno";
      args = ["run" "--allow-net" "--allow-env" "https://raw.githubusercontent.com/sigmaSd/helix-gpt/0.34-deno/src/app.ts"];
      # environment.HANDLER = "openai";
      # environment.OPENAI_MODEL = "gpt-4o-mini";
      environment.HANDLER = "codeium";
    };

    languages.language = [
      {
        name = "markdown";
        auto-format = true;
        formatter.command = "biome";
        formatter.args = ["format" "--stdin-file-path" "buffer.md"];
      }

      {
        name = "javascript";
        auto-format = true;
        formatter.command = "biome";
        formatter.args = ["format" "--stdin-file-path" "buffer.js"];
        language-servers = ["typescript-language-server" "biome" "gpt"];
      }

      {
        name = "jsx";
        auto-format = true;
        formatter.command = "biome";
        formatter.args = ["format" "--stdin-file-path" "buffer.jsx"];
        language-servers = ["typescript-language-server" "biome" "gpt"];
      }

      {
        name = "typescript";
        auto-format = true;
        formatter.command = "biome";
        formatter.args = ["format" "--stdin-file-path" "buffer.ts"];
        language-servers = ["typescript-language-server" "biome" "gpt"];
      }

      {
        name = "tsx";
        auto-format = true;
        formatter.command = "biome";
        formatter.args = ["format" "--stdin-file-path" "buffer.tsx"];
        language-servers = ["typescript-language-server" "biome" "gpt"];
      }

      {
        name = "nix";
        auto-format = true;
        formatter.command = "alejandra";
      }

      # My own languages :)
      {
        name = "aspen";
        scope = "source.aspen";
        file-types = ["aspen"];
        injection-regex = "^aspen$";
        comment-tokens = "//";
        indent = {
          tab-width = 2;
          unit = "  ";
        };
        language-servers = ["aspen-lsp"];
        grammar = "aspen";
        formatter = {
          command = "/Users/emilbroman/code/aspen-lang/target/release/aspen";
          args = ["format"];
        };
        auto-format = true;
      }
    ];

    languages.grammar = [
      {
        name = "aspen";
        source.path = "/Users/emilbroman/code/aspen-lang/tree-sitter-aspen";
      }
    ];

    languages.language-server.aspen-lsp = {
      command = "/Users/emilbroman/code/aspen-lang/target/release/aspen";
      args = ["lsp"];
    };

    themes.${themeName} = {
      "ui.window" = palette.gray."250";
      "ui.background" = palette.gray."250";

      "ui.text" = palette.gray."150";
      "ui.selection" = {bg = palette.gray."300";};

      "ui.linenr" = palette.gray."300";
      "ui.linenr.selected" = palette.gray."250";
      "ui.cursor.primary" = {bg = palette.gray."150";};
      "ui.popup" = {
        bg = palette.gray."300";
        fg = palette.gray."150";
      };
      "ui.menu" = {
        bg = palette.gray."300";
        fg = palette.gray."150";
      };
      "ui.menu.selected" = {bg = palette.gray."250";};
      "ui.help" = {
        bg = palette.gray."300";
        fg = palette.gray."150";
      };

      "diff.plus.gutter" = {fg = palette.green."300";};
      "diff.minus.gutter" = {fg = palette.red."300";};
      "diff.delta.gutter" = {fg = palette.orange."300";};

      "ui.statusline" = {
        bg = palette.gray."200";
        fg = palette.gray."300";
      };
      "ui.statusline.inactive" = {
        bg = palette.gray."300";
        fg = palette.gray."200";
      };

      "ui.virtual.ruler" = palette.gray."300";

      "special" = palette.orange."300";
      "error" = palette.red."400";
      "diagnostic.error" = {
        fg = palette.red."400";
        underline = {
          color = palette.red."400";
          style = "curl";
        };
      };
      "warning" = palette.yellow."400";
      "diagnostic.warning" = {
        underline = {
          color = palette.yellow."400";
          style = "dashed";
        };
      };
      "hint" = palette.blue."400";
      "diagnostic.hint" = {
        underline = {
          color = palette.blue."400";
          style = "dashed";
        };
      };

      "diagnostic.unnecessary" = {
        fg = palette.gray."250";
        modifiers = ["italic"];
        underline = {
          color = palette.blue."400";
          style = "dashed";
        };
      };

      "diagnostic.deprecated" = {
        modifiers = ["crossed_out"];
      };

      # Syntax highlighting

      "keyword" = {
        fg = palette.blue."350";
        modifiers = ["bold"];
      };

      "type" = palette.red."300";
      "constructor" = palette.red."250";

      "variable.builtin" = {
        fg = palette.blue."250";
        modifiers = ["bold"];
      };
      "variable" = {fg = palette.orange."200";};

      "string" = palette.green."200";
      "string.special.symbol" = palette.blue."200";

      "function" = palette.blue."200";

      "comment" = {
        bg = palette.gray."300";
        fg = palette.gray."100";
        modifiers = ["italic"];
      };

      "punctuation" = palette.gray."250";
      "operator" = palette.gray."200";
      "namespace" = palette.magenta."100";
      "constant" = palette.yellow."200";
      "label" = palette.blue."250";
    };
  };
}
