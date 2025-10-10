let
  themeName = "emil";
in {
  programs.helix = {
    enable = true;

    defaultEditor = true;

    themes.${themeName} =
      (import ./themes.nix).current.helix;

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
        language-servers = ["typescript-language-server" "gpt"];
      }

      {
        name = "jsx";
        auto-format = true;
        language-servers = ["typescript-language-server" "gpt"];
      }

      {
        name = "typescript";
        auto-format = true;
        language-servers = ["typescript-language-server" "gpt"];
      }

      {
        name = "tsx";
        auto-format = true;
        language-servers = ["typescript-language-server" "gpt"];
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
  };
}
