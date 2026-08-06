{
  inputs = {
    tvm-cli.url = "git+ssh://git@github.com/TV4/tvm-cli";
    tvm-cli.flake = false;

    claude-plugins.url = "git+ssh://git@github.com/TV4/claude-plugins";
    claude-plugins.flake = false;
  };

  outputs = {
    self,
    tvm-cli,
    claude-plugins,
  }: {
    system-module = {
      nix-homebrew = {
        trust.taps = ["TV4/tvm-cli"];
        taps."TV4/tvm-cli" = tvm-cli;
      };

      homebrew.brews = ["tvm" "tvm-aws" "tvm-infra"];
    };

    home-module = {
      programs.claude-code.marketplaces = {
        tvm = claude-plugins;
      };
      programs.claude-code.settings = {
        enabledPlugins = {
          "tvm-aws-sso@tvm" = true;
          "tvm-templates@tvm" = true;
          "tvm-docs@tvm" = true;
        };
      };
    };
  };
}
