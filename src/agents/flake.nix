{
  outputs = {self}: {
    system-module = {lib, ...}: {
      nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) ["claude-code"];
    };

    home-module = {theme}: {
      pkgs,
      lib,
      config,
      ...
    }: let
      hooks = {
        adrafinilTool,
        harnessName,
      }: {
        Stop = [
          {
            hooks = [
              {
                command = "/Applications/Adrafinil.app/Contents/Helpers/adrafinil release --tool ${adrafinilTool}";
                type = "command";
              }
            ];
          }
        ];
        SubagentStart = [
          {
            hooks = [
              {
                command = "/Applications/Adrafinil.app/Contents/Helpers/adrafinil acquire --tool ${adrafinilTool} --subagent";
                type = "command";
              }
            ];
          }
        ];
        SubagentStop = [
          {
            hooks = [
              {
                command = "/Applications/Adrafinil.app/Contents/Helpers/adrafinil release --tool ${adrafinilTool} --subagent";
                type = "command";
              }
            ];
          }
        ];
        UserPromptSubmit = [
          {
            hooks = [
              {
                command = "/Applications/Adrafinil.app/Contents/Helpers/adrafinil acquire --tool ${adrafinilTool}";
                type = "command";
              }
            ];
          }
        ];
        Notification = [
          {
            hooks = [
              {
                type = "command";
                command = lib.strings.concatStringsSep " " [
                  (lib.getExe pkgs.terminal-notifier)
                  "-title '${harnessName} is waiting'"
                  "-message \"in \${CLAUDE_PROJECT_DIR/\$HOME/~}\""
                  "-sound Glass"
                ];
              }
            ];
          }
        ];
      };

      workIngestHooks = let
        entry = extra: [
          {
            hooks = [
              ({
                  type = "command";
                  command = "${lib.getExe pkgs.python3} ${config.home.homeDirectory}/.config/work/work-ingest.py";
                  timeout = 60;
                }
                // extra)
            ];
          }
        ];
      in {
        # Stop uploads every turn, so a running session is already visible in
        # Work; the other two run synchronously because the session or its
        # transcript is about to stop existing in its current form.
        Stop = entry {async = true;};
        SessionEnd = entry {};
        PreCompact = entry {};
      };
    in {
      programs.codex = {
        enable = true;
        context = ./AGENTS.md;
        skills = ./skills;

        hooks = lib.optionalAttrs pkgs.stdenv.isDarwin (hooks {
          adrafinilTool = "codex";
          harnessName = "Codex";
        });

        settings = {
          approval_policy = "on-request";
          approvals_reviewer = "auto_review";

          hooks.state = let
            h = "${config.home.homeDirectory}/.codex/hooks.json";
          in {
            "${h}:user_prompt_submit:0:0".trusted_hash = "sha256:0fa90362de5751e5c8c74bd52f5ba4ffdfe66385f13532892518ceb68d3cc955";
            "${h}:subagent_start:0:0".trusted_hash = "sha256:5cb71f2ee92443b08bda1a30ec4535354df7f28c766116617dd1b39db938c697";
            "${h}:subagent_stop:0:0".trusted_hash = "sha256:93f2b97619da3776c1f982f46ca08f226b5d7813669fa1045840e2fa819f60f0";
            "${h}:stop:0:0".trusted_hash = "sha256:8891077ffdd313425e969af792c8d538146f433b2e3a9929631cfd53ee2c8e7a";
          };
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

          hooks = lib.zipAttrsWith (_: lib.concatLists) [
            (lib.optionalAttrs pkgs.stdenv.isDarwin (hooks {
              adrafinilTool = "claude";
              harnessName = "Claude Code";
            }))
            workIngestHooks
          ];
        };
      };
    };
  };
}
