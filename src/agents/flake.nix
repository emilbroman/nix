{
  inputs = {
    claude-plugins-official.url = "git+ssh://git@github.com/anthropics/claude-plugins-official";
    claude-plugins-official.flake = false;

    mattpocock-skills.url = "git+ssh://git@github.com/mattpocock/skills";
    mattpocock-skills.flake = false;

    openai-plugins.url = "github:openai/plugins";
    openai-plugins.flake = false;
  };

  outputs = {
    claude-plugins-official,
    mattpocock-skills,
    openai-plugins,
    self,
  }: {
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

      # openai/plugins names its marketplace `openai-curated`, which Codex
      # reserves for its own built-in copy and so drops when configured. The
      # manifest is rewritten under a name of our own.
      openaiMarketplace = pkgs.runCommand "openai-plugins-marketplace" {nativeBuildInputs = [pkgs.jq];} ''
        mkdir -p $out/.agents/plugins
        ln -s ${openai-plugins}/plugins $out/plugins
        jq '.name = "openai"' ${openai-plugins}/.agents/plugins/marketplace.json > $out/.agents/plugins/marketplace.json
      '';

      # A marketplace plugin only loads once it is installed into Codex's
      # cache, which `codex plugin add` does by copying the plugin root there.
      # It can't be a link into the store: Codex skips a plugin whose manifest
      # is a symlink, while still listing it as installed.
      codexPlugins = {
        linear = {
          marketplace = "openai";
          marketplaceSource = openaiMarketplace;
          source = "${openai-plugins}/plugins/linear";
          manifest = ".codex-plugin/plugin.json";
        };
        mattpocock-skills = {
          marketplace = "mattpocock";
          source = mattpocock-skills;
          manifest = ".claude-plugin/plugin.json";
        };
      };

      codexPluginCacheDir = name: plugin: "${config.home.homeDirectory}/.codex/plugins/cache/${plugin.marketplace}/${name}";
    in {
      programs.codex = {
        enable = true;
        context = ./AGENTS.md;
        skills = ./skills;

        # The desktop app installs its bundled plugins (computer-use and the
        # unified-computer-use MCP backend it relies on) by registering the
        # `openai-bundled` marketplace and enabling them in config.toml. A
        # store symlink makes those writes fail, so keep config.toml a real
        # file and merge the declared settings over it on activation instead.
        mutableSettings = true;

        hooks = lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin (hooks {
          adrafinilTool = "codex";
          harnessName = "Codex";
        });

        settings = {
          approval_policy = "never";
          sandbox_mode = "danger-full-access";

          hooks.state = codexHookState;

          plugins = (lib.mapAttrs' (name: plugin: lib.nameValuePair "${name}@${plugin.marketplace}" {enabled = true;}) codexPlugins) // {
            "computer-use@openai-bundled".enabled = true;
          };
        };

        marketplaces = lib.mapAttrs' (_: plugin: lib.nameValuePair plugin.marketplace (plugin.marketplaceSource or plugin.source)) codexPlugins;
      };

      home.activation.installCodexPlugins = lib.hm.dag.entryAfter ["writeBoundary"] (lib.concatStrings (lib.mapAttrsToList (name: plugin: let
          cacheDir = lib.escapeShellArg (codexPluginCacheDir name plugin);
          version = (builtins.fromJSON (builtins.readFile "${plugin.source}/${plugin.manifest}")).version;
        in ''
          # The marker holds the store path that was copied, so a new revision
          # replaces the copy even when the plugin's version is unchanged.
          if [[ "$(cat ${cacheDir}/.nix-source 2>/dev/null)" != ${plugin.source} ]]; then
            if [[ -e ${cacheDir} ]]; then
              run chmod -R u+w ${cacheDir}
              run rm -rf ${cacheDir}
            fi
            run mkdir -p ${cacheDir}
            run cp -R ${plugin.source} ${cacheDir}/${lib.escapeShellArg version}
            run chmod -R u+w ${cacheDir}/${lib.escapeShellArg version}
            [[ -v DRY_RUN ]] || echo ${plugin.source} > ${cacheDir}/.nix-source
          fi
        '')
        codexPlugins));

      programs.claude-code = {
        enable = true;
        context = ./AGENTS.md;
        skills = ./skills;

        marketplaces = {
          cpo = claude-plugins-official;
        };

        settings = {
          voice.enabled = true;
          voice.mode = "tap";

          permissions.defaultMode = "bypassPermissions";
          skipDangerousModePermissionPrompt = true;
          enabledPlugins = {
            "rust-analyzer-lsp@cpo" = true;
            "typescript-lsp@cpo" = true;
            "code-review@cpo" = true;
            "playwright@cpo" = true;
            "frontend-design@cpo" = true;
            "mattpocock-skills@cpo" = true;
          };
          tui = "fullscreen";

          hooks = lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin (hooks {
            adrafinilTool = "claude";
            harnessName = "Claude Code";
          });
        };
      };

      programs.opencode = let
        # Every model goes through the bb3 LiteLLM gateway, which only routes
        # ids carrying the prefix of their upstream. Each provider here borrows
        # a catalog provider's wire protocol through `canonical` but holds only
        # the models listed, and each model inherits its catalog entry (limits,
        # capabilities) by name, with `modelID` rewriting the id on the wire.
        #
        # They are providers of their own rather than overrides of the built-in
        # ones for two reasons: a built-in provider keeps its whole catalog,
        # which the gateway mostly won't route, and its env vars
        # (OPENAI_API_KEY, MELIOUS_API_KEY) take precedence over a configured
        # apiKey.
        bb3 = canonical: name: prefix: models: {
          inherit canonical name;
          settings = {
            baseURL = "https://litellm.bb3.internal/v1";
            # A personal virtual key, minted in the gateway's UI.
            apiKey = "{env:BB3_LITELLM_API_KEY}";
          };
          models = lib.genAttrs models (model: {modelID = "${prefix}/${model}";});
        };
      in {
        enable = true;
        context = ./AGENTS.md;
        skills = ./skills;

        settings = {
          # The catalog providers the ones below stand in for.
          disabled_providers = ["anthropic" "openai" "melious"];

          providers = {
            bb3-anthropic = bb3 "anthropic" "Anthropic (bb3)" "anthropic" [
              "claude-fable-5-1"
              "claude-opus-5-5"
              "claude-sonnet-5-5"
              "claude-haiku-5-5"
            ];

            # The ChatGPT subscription, over the Responses API. The gateway
            # retries a failed request on the paid `openai/` route.
            bb3-chatgpt = bb3 "openai" "ChatGPT (bb3)" "chatgpt" [
              "gpt-6-astra"
              "gpt-6.1-sol"
              "gpt-6.1-terra"
              "gpt-6-luna"
            ];

            bb3-melious = bb3 "melious" "Melious (bb3)" "melious" [
              "deepseek-v4.1-flash-1017"
            ];
          };
        };
      };
    };
  };
}
