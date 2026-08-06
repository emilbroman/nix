{
  inputs = {
    skyr-agent-plugin.url = "github:skyr-cloud/agent-plugin";
    skyr-agent-plugin.flake = false;

    tree-sitter-scl.url = "github:skyr-cloud/tree-sitter-scl";
    tree-sitter-scl.flake = false;
    tree-sitter-scle.url = "github:skyr-cloud/tree-sitter-scle";
    tree-sitter-scle.flake = false;
  };
  outputs = {
    skyr-agent-plugin,
    tree-sitter-scl,
    tree-sitter-scle,
    self,
  }: {
    home-module = {pkgs, ...}: let
      # Parser and queries must come from one source tree. Helix compiles the
      # parser separately from loading the queries, and a query that names a
      # node the parser lacks fails to compile as a whole — which drops all
      # highlighting for the language, with the error going only to the log.
      # Building both from the same input makes `nix flake update` move them
      # together.
      sclGrammar = pkgs.tree-sitter.buildGrammar {
        language = "scl";
        version = tree-sitter-scl.shortRev;
        src = tree-sitter-scl;
      };
      scleGrammar = pkgs.tree-sitter.buildGrammar {
        language = "scle";
        version = tree-sitter-scle.shortRev;
        src = tree-sitter-scle;
      };
    in {
      # Nix builds the parsers rather than `hx --grammar fetch && hx --grammar
      # build`, which cannot track a moving input: given a branch name as the
      # revision it checks the branch out once and never fast-forwards, and
      # given a store path it decides whether to rebuild by comparing mtimes,
      # which in the store are all 1970 and so never newer than the parser it
      # has already built.
      home.file.".config/helix/runtime/grammars/scl.so".source = "${sclGrammar}/parser";
      home.file.".config/helix/runtime/grammars/scle.so".source = "${scleGrammar}/parser";

      home.file.".config/helix/runtime/queries/scl".source = "${sclGrammar}/queries";
      home.file.".config/helix/runtime/queries/scle".source = "${scleGrammar}/queries";

      programs.helix.languages = {
        language-server.scl = {
          command = "skyr";
          args = ["lsp"];
        };

        language = [
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
      };

      # Add plugin to Codex
      programs.codex.marketplaces = {skyr-cloud = skyr-agent-plugin;};

      programs.claude-code = {
        # Add plugin to Claude Code
        marketplaces = {skyr-cloud = skyr-agent-plugin;};
        settings.enabledPlugins."skyr@skyr-cloud" = true;

        # Teach Claude Code about the LSP
        lspServers = {
          skyr = {
            command = "skyr";
            args = ["lsp"];
            extensionToLanguage = {
              ".scl" = "scl";
              ".scle" = "scle";
            };
          };
        };
      };
    };
  };
}
