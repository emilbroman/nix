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
    system-module = {user}: {
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

      homebrew.casks = [
        "figma"
        "docker"
        "google-chrome"
        "slack"
        "mongodb-compass"
        "notion"
        "firefox"
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
