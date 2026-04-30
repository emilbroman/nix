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
      imports = let
        mkSkill = frontmatter: content:
          pkgs.writeTextDir "${frontmatter.name}/SKILL.md" ''
            ---
            ${builtins.toJSON frontmatter}
            ---
            ${content}
          '';

        mkSkills = skills:
          pkgs.symlinkJoin {
            name = "skills";
            paths = skills;
          };

        skills = [
          ./skills
          (mkSkill {
              name = "test-skill";
              description = "A test skill that should be used whenever the user requests accessing the test skill with the password XYZABC";
            } ''
              # Test Skill
              This skill is just a test, with the sole purpose of testing that skill loading is working correctly.

              So, when this skill is loaded, respond directly to the user with **nothing other than** exactly `yes sir`.
            '')
        ];

        settings = {
          theme = theme.pi;
          quietStartup = true;
          collapseChangelog = true;
          enableInstallTelemetry = false;
          warnings.anthropicExtraUsage = false;
          npmCommand = [(lib.getExe' pkgs.nodejs_25 "npm")];
          shellPath = lib.getExe pkgs.fish;
          packages = [
            "npm:@gotgenes/pi-anthropic-auth"
            "npm:pi-lens"
          ];
          extensions = [];
          skills = [(mkSkills skills)];
          prompts = [];
          themes = [];
        };
        agents = [
          {
            name = "home";
            settings = {
              defaultProvider = "anthropic";
              defaultModel = "claude-opus-4-7";
              defaultThinkingLevel = "medium";
              enabledModels = ["claude-*"];
            };
          }
          {
            name = "tv4";
            settings = {
              defaultProvider = "anthropic";
              defaultModel = "claude-opus-4-7";
              defaultThinkingLevel = "xhigh";
              enabledModels = ["claude-*" "gpt-*"];
            };
          }
        ];

        mkAgent = cfg: {
          pkgs,
          lib,
          ...
        }: let
          agentDir = ".pi/agents/${cfg.name}";
        in {
          home.packages = [
            (pkgs.writeShellScriptBin "pi@${cfg.name}" ''
              export PI_CODING_AGENT_DIR="$HOME/${agentDir}"
              export PATH="${lib.getBin pkgs.nodejs_25}:$PATH"
              [ -f flake.nix ] && exec nix develop -c ${lib.getExe pkgs.pi-coding-agent} "$@"
              exec ${lib.getExe pkgs.pi-coding-agent} "$@"
            '')
          ];

          home.file."${agentDir}/settings.json".text = builtins.toJSON (settings
            // {
              sessionDir = "${agentDir}/sessions";
            }
            // cfg.settings);
        };
      in
        map mkAgent agents;

      home.packages = with pkgs; [
        claude-code
      ];

      programs.git.ignores = [
        ".claude/"
        ".pi/"
        ".pi-lens/"
      ];

      home.file.".claude/CLAUDE.md".source = ./AGENTS.md;
      home.file.".codex/AGENTS.md".source = ./AGENTS.md;

      home.file.".claude/skills".source = ./skills;
      home.file.".codex/skills".source = ./skills;

      home.file.".claude/settings.json".text = builtins.toJSON {
        enabledPlugins = {
          "tvm-aws-sso@tvm" = true;
          "tvm-templates@tvm" = true;
          "rust-analyzer-lsp@claude-plugins-official" = true;
          "typescript-lsp@claude-plugins-official" = true;
          "code-review@claude-plugins-official" = true;
          "playwright@claude-plugins-official" = true;
          "frontend-design@claude-plugins-official" = true;
        };
        extraKnownMarketplaces = {
          tvm.source = {
            source = "github";
            repo = "TV4/claude-plugins";
          };
        };
        hooks = {
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
}
