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

      # Codex only runs a hook whose identity it has been told to trust, and the
      # trust its review screen writes can never land in a config.toml that is a
      # symlink into the store. Deriving the state from the declared hooks keeps
      # every one of them trusted, wherever in this flake it was added.
      codexHooksPath = "${config.home.homeDirectory}/.codex/hooks.json";

      codexEventKeys = {
        PreToolUse = "pre_tool_use";
        PermissionRequest = "permission_request";
        PostToolUse = "post_tool_use";
        PreCompact = "pre_compact";
        PostCompact = "post_compact";
        SessionStart = "session_start";
        SessionEnd = "session_end";
        UserPromptSubmit = "user_prompt_submit";
        SubagentStart = "subagent_start";
        SubagentStop = "subagent_stop";
        Stop = "stop";
        Interrupt = "interrupt";
      };

      # SessionEnd and Interrupt hooks run while Codex is tearing down: it
      # defaults them to a second and caps them at three, and hashes the capped
      # value. Everything else defaults to ten minutes.
      codexTimeout = event: handler:
        if event == "SessionEnd" || event == "Interrupt"
        then lib.min 3 (lib.max 1 (handler.timeout or 1))
        else lib.max 1 (handler.timeout or 600);

      # The hash covers the canonical JSON of the event, the group carrying this
      # one handler, and the defaults Codex fills in — `hook_hash` in
      # codex-rs/hooks/src/engine/discovery.rs. Nix writes attribute names
      # sorted and unspaced, which is that canonical form. A matcher is taken as
      # declared, and Codex normalizes those per event, so a hook that needs one
      # normalized would land back on the review screen rather than run.
      codexTrustedHash = event: group: handler:
        "sha256:"
        + builtins.hashString "sha256" (builtins.toJSON ({
            event_name = codexEventKeys.${event};
            hooks = [({async = false;} // handler // {timeout = codexTimeout event handler;})];
          }
          // lib.optionalAttrs (group ? matcher) {inherit (group) matcher;}));

      codexHookState = lib.listToAttrs (lib.concatLists (lib.mapAttrsToList (
          event: groups:
            lib.concatLists (lib.imap0 (
                groupIndex: group:
                  lib.imap0 (handlerIndex: handler: {
                    name = "${codexHooksPath}:${codexEventKeys.${event}}:${toString groupIndex}:${toString handlerIndex}";
                    value.trusted_hash = codexTrustedHash event group handler;
                  })
                  group.hooks
              )
              groups)
        )
        # An event Codex doesn't know is dropped when it reads hooks.json, and
        # never asked about, so it has no trust state either.
        (lib.filterAttrs (event: _: codexEventKeys ? ${event}) config.programs.codex.hooks)));
    in {
      programs.codex = {
        enable = true;
        context = ./AGENTS.md;
        skills = ./skills;

        hooks = lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin (hooks {
          adrafinilTool = "codex";
          harnessName = "Codex";
        });

        settings = {
          approval_policy = "never";
          sandbox_mode = "danger-full-access";

          hooks.state = codexHookState;
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

          voice.enabled = true;
          voice.mode = "tap";

          permissions.defaultMode = "bypassPermissions";
          skipDangerousModePermissionPrompt = true;
          enabledPlugins = {
            "rust-analyzer-lsp@claude-plugins-official" = true;
            "typescript-lsp@claude-plugins-official" = true;
            "code-review@claude-plugins-official" = true;
            "playwright@claude-plugins-official" = true;
            "frontend-design@claude-plugins-official" = true;
          };
          tui = "fullscreen";

          hooks = lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin (hooks {
            adrafinilTool = "claude";
            harnessName = "Claude Code";
          });
        };
      };
    };
  };
}
