{
  outputs = {self}: {
    home-module = {
      pkgs,
      lib,
      ...
    }: {
      home.packages = with pkgs; [
        codex
        claude-code
      ];

      home.file.".claude/CLAUDE.md".source = ./AGENTS.md;
      home.file.".codex/AGENTS.md".source = ./AGENTS.md;

      home.file.".claude/skills".source = ./skills;
      home.file.".codex/skills".source = ./skills;

      home.file.".claude/settings.json".text = builtins.toJSON {
        enabledPlugins = {
          "tvm-aws-sso@tvm" = true;
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
