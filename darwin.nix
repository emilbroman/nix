{pkgs, ...}: {
  imports = [
    ./configuration.nix
    ./users/darwin.nix
  ];

  system.stateVersion = 4;

  services.nix-daemon.enable = true;

  homebrew.enable = true;
  homebrew.casks = [
    "wezterm"
    "docker"
  ];
  homebrew.onActivation = {
    autoUpdate = false;
    cleanup = "zap";
  };

  environment.systemPackages = with pkgs; [
    skhd # macOS keyboard shortcuts
  ];

  system.defaults.NSGlobalDomain.InitialKeyRepeat = 10;
  system.defaults.NSGlobalDomain.KeyRepeat = 3;

  home-manager.sharedModules = [
    {
      # Toggle WezTerm using F13
      home.file.".config/skhd/skhdrc".text = ''
        f13 [
          "wezterm" : osascript -e 'tell application "System Events" to set visible of process "WezTerm" to false'
          *         : osascript -e 'activate application "WezTerm"'
        ]
      '';

      programs.fish.functions.nix-rebuild = ''
        sudo true
        and darwin-rebuild switch --flake ~/code/nix
      '';
    }
  ];
}
