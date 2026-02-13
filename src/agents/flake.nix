{
  outputs = {self}: {
    home-module = {pkgs, ...}: {
      home.packages = with pkgs; [
        codex
        claude-code
      ];

      home.file.".claude/CLAUDE.md".source = ./AGENTS.md;
      home.file.".codex/AGENTS.md".source = ./AGENTS.md;

      home.file.".claude/skills".source = ./skills;
      home.file.".codex/skills".source = ./skills;
    };
  };
}
