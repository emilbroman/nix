{
  outputs = {self}: {
    system-module = {lib, ...}: {
      nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) ["claude-code"];
    };

    home-module = {theme}: {
      pkgs,
      lib,
      ...
    }: {
      programs.codex = {
        enable = true;
        context = ./AGENTS.md;
        skills = ./skills;

        settings = {
          approval_policy = "on-request";
          approvals_reviewer = "auto_review";
        };
      };

      programs.claude-code = {
        enable = true;
        context = ./AGENTS.md;
        skills = ./skills;

        settings = {
          extraKnownMarketplaces = {
            claude-plugins-official = {
              source = {
                source = "github";
                repo = "anthropics/claude-plugins-official";
              };
            };
          };

          permissions.defaultMode = "auto";
          permissions.skipDangerousModePermissionPrompt = true;
          enabledPlugins = {
            "rust-analyzer-lsp@claude-plugins-official" = true;
            "typescript-lsp@claude-plugins-official" = true;
            "code-review@claude-plugins-official" = true;
            "playwright@claude-plugins-official" = true;
            "frontend-design@claude-plugins-official" = true;
          };
          tui = "fullscreen";
          hooks = lib.optionalAttrs pkgs.stdenv.isDarwin {
            Notification = [
              {
                matcher = "";
                hooks = [
                  {
                    type = "command";
                    command = lib.strings.concatStringsSep " " [
                      (lib.getExe pkgs.terminal-notifier)
                      "-title 'Claude Code is waiting'"
                      "-message \"in \${CLAUDE_PROJECT_DIR/\$HOME/~}\""
                      "-sound Glass"
                    ];
                  }
                ];
              }
            ];
          };
        };
      };
    };
  };
}
