{
  inputs = {
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    zed.url = ./../../../zed;
    wezterm.url = ./../../../wezterm;
  };

  outputs = {
    self,
    nix-homebrew,
    zed,
    wezterm,
  }: {
    system-module = {user}: {pkgs, ...}: {
      imports = [
        nix-homebrew.darwinModules.nix-homebrew
        zed.system-module
        wezterm.system-module
      ];

      nix-homebrew = {
        enable = true;
        user = user;
      };

      homebrew.enable = true;
      homebrew.onActivation = {
        autoUpdate = false;
        cleanup = "zap";
      };

      environment.systemPackages = with pkgs; [
        podman
        podman-compose
        (writeShellScriptBin "docker" ''
          exec podman "$@"
        '')
      ];

      homebrew.casks = [
        "figma"
        "google-chrome"
        "slack"
        "mongodb-compass"
        "notion"
        "firefox"
        "podman-desktop"
      ];
    };

    home-module = {theme}: {
      imports = [
        (zed.home-module {inherit theme;})
        (wezterm.home-module {inherit theme;})
      ];
    };
  };
}
