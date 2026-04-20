{
  outputs = {self}: {
    system-module = {lib, ...}: {
      nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) ["claude-code"];
    };

    home-module = {
      pkgs,
      lib,
      ...
    }: {
      home.packages = with pkgs; [
        codex
        claude-code
        (writeShellScriptBin "new-claude" ''
          dir="$(${lib.getExe fzf} --walker=dir,follow,hidden --walker-root="$HOME/code")"

          [ -n "$dir" ] || exit 0

          cd "$dir" || exit 1

          export PATH="$HOME/.nix-profile/bin:/run/current-system/sw/bin:$PATH"

          [ -f flake.nix ] && exec nix develop -c ${lib.getExe claude-code} --allow-dangerously-skip-permissions "$@"

          exec ${lib.getExe claude-code} --allow-dangerously-skip-permissions "$@"
        '')
      ];

      home.file.".claude/CLAUDE.md".source = ./AGENTS.md;
      home.file.".codex/AGENTS.md".source = ./AGENTS.md;

      home.file.".claude/skills".source = ./skills;
      home.file.".codex/skills".source = ./skills;

      home.file.".claude/settings.json".text = builtins.toJSON {
        enabledPlugins = {
          "tvm-aws-sso@tvm" = true;
          "rust-analyzer-lsp@claude-plugins-official" = true;
          "typescript-lsp@claude-plugins-official" = true;
          "code-review@claude-plugins-official" = true;
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
