{
  inputs = {
    tvm-cli.url = "git+ssh://git@github.com/TV4/tvm-cli";
    tvm-cli.flake = false;

    claude-plugins.url = "git+ssh://git@github.com/TV4/claude-plugins";
    claude-plugins.flake = false;

    work.url = "git+ssh://git@github.com/TV4/work";
    work.flake = false;
  };

  outputs = {
    self,
    tvm-cli,
    claude-plugins,
    work,
  }: {
    system-module = {
      nix-homebrew = {
        trust.taps = ["TV4/tvm-cli"];
        taps."TV4/tvm-cli" = tvm-cli;
      };

      homebrew.brews = ["tvm" "tvm-aws" "tvm-infra"];
    };

    home-module = {
      pkgs,
      lib,
      ...
    }: let
      # Ships a session's transcript to Work, so a session run here shows up
      # there as an external session. It uploads only sessions started in a
      # github.com/TV4 checkout, and reads its ingest token from
      # ~/.config/work/ingest-token, which is kept outside this flake.
      # See components/runtime-service/hooks/README.md in TV4/work.
      ingest = extra: [
        {
          hooks = [
            ({
                type = "command";
                command = "${lib.getExe pkgs.python3} ${work}/components/runtime-service/hooks/work-ingest.py";
                timeout = 60;
              }
              // extra)
          ];
        }
      ];
    in {
      programs.claude-code.marketplaces = {
        tvm = claude-plugins;
      };
      programs.claude-code.settings = {
        enabledPlugins = {
          "tvm-aws-sso@tvm" = true;
          "tvm-templates@tvm" = true;
          "tvm-docs@tvm" = true;
        };

        # Stop uploads every turn, so a running session is already visible in
        # Work; the other two run synchronously because the session or its
        # transcript is about to stop existing in its current form. SessionEnd
        # is also the one that settles the session out of Work's working list.
        hooks = {
          Stop = ingest {async = true;};
          SessionEnd = ingest {};
          PreCompact = ingest {};
        };
      };

      # The same three events in Codex, which runs a SessionEnd hook
      # synchronously whatever `async` says and caps it at three seconds — ask
      # for the three rather than take a clamp warning on every session.
      programs.codex.hooks = {
        Stop = ingest {async = true;};
        SessionEnd = ingest {timeout = 3;};
        PreCompact = ingest {};
      };
    };
  };
}
