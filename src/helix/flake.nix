{
  outputs = {self}: {
    home-module = let
      themeName = "custom";
    in ({theme}: {
      pkgs,
      config,
      ...
    }: {
      home.file.".config/helix/runtime/queries/scl".source =
        config.lib.file.mkOutOfStoreSymlink
        "/Users/emilbroman/code/skyr/crates/sclc/tree-sitter-scl/queries";
      home.file.".config/helix/runtime/queries/scle".source =
        config.lib.file.mkOutOfStoreSymlink
        "/Users/emilbroman/code/skyr/crates/sclc/tree-sitter-scle/queries";

      home.packages = with pkgs; [
        helix

        # Web
        biome

        # Nix
        nil
        alejandra

        # Markdown
        marksman

        # Typst
        tinymist

        # Go
        gopls
      ];

      programs.helix = {
        enable = true;

        defaultEditor = true;

        themes.${themeName} = theme.helix;

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

        languages.language = [
          {
            name = "markdown";
            auto-format = true;
            formatter.command = "biome";
            formatter.args = ["format" "--stdin-file-path" "buffer.md"];
          }

          {
            name = "html";
            auto-format = true;
            formatter.command = "biome";
            formatter.args = ["format" "--stdin-file-path" "buffer.html"];
          }

          {
            name = "javascript";
            auto-format = true;
            language-servers = ["typescript-language-server"];
          }

          {
            name = "jsx";
            auto-format = true;
            language-servers = ["typescript-language-server"];
          }

          {
            name = "typescript";
            auto-format = true;
            formatter.command = "biome";
            formatter.args = ["format" "--stdin-file-path" "buffer.ts"];
            language-servers = ["typescript-language-server" "biome"];
          }

          {
            name = "tsx";
            auto-format = true;
            formatter.command = "biome";
            formatter.args = ["format" "--stdin-file-path" "buffer.tsx"];
            language-servers = ["typescript-language-server" "biome"];
          }

          {
            name = "nix";
            auto-format = true;
            formatter.command = "alejandra";
          }

          {
            name = "scl";
            language-servers = ["scl"];
            scope = "source.scl";
            file-types = ["scl"];
            injection-regex = "^(scl|skyr)$";
            comment-tokens = "//";
            auto-format = true;
            indent = {
              tab-width = 2;
              unit = "  ";
            };
            grammar = "scl";
          }

          {
            name = "scle";
            language-servers = ["scl"];
            scope = "source.scle";
            file-types = ["scle"];
            injection-regex = "^(scle|skyr)$";
            comment-tokens = "//";
            auto-format = true;
            indent = {
              tab-width = 2;
              unit = "  ";
            };
            grammar = "scle";
          }
        ];

        languages.grammar = [
          {
            name = "scl";
            source.path = "/Users/emilbroman/code/skyr/crates/sclc/tree-sitter-scl";
          }
          {
            name = "scle";
            source.path = "/Users/emilbroman/code/skyr/crates/sclc/tree-sitter-scle";
          }
        ];

        languages.language-server.scl = {
          command = "/Users/emilbroman/code/skyr/target/release/skyr";
          args = ["lsp"];
        };
      };
    });
  };
}
