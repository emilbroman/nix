{
  outputs = {self}: {
    home-module = let
      themeName = "custom";
    in ({theme}: {pkgs, ...}: {
      home.packages = with pkgs; [
        helix

        # Web
        biome

        # Nix
        nil
        alejandra

        # Markdown
        marksman

        # TypeScript
        nodePackages.typescript-language-server

        # Typst
        tinymist
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
        ];
      };
    });
  };
}
