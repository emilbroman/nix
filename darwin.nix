{pkgs, ...}: {
  imports = [
    ./configuration.nix
    ./users/darwin.nix
  ];

  system.stateVersion = 4;

  services.nix-daemon.enable = true;

  nix-homebrew = {
    enable = true;
    user = "emilbroman";
  };

  homebrew.enable = true;
  homebrew.onActivation = {
    autoUpdate = false;
    cleanup = "zap";
  };

  environment.systemPackages = with pkgs; [
    skhd # macOS keyboard shortcuts
  ];

  # Keyboard Settings
  system.defaults.NSGlobalDomain = {
    InitialKeyRepeat = 9;
    KeyRepeat = 2;

    NSAutomaticCapitalizationEnabled = false;
    NSAutomaticDashSubstitutionEnabled = false;
    NSAutomaticInlinePredictionEnabled = false;
    NSAutomaticPeriodSubstitutionEnabled = false;
    NSAutomaticQuoteSubstitutionEnabled = false;
    NSAutomaticSpellingCorrectionEnabled = false;
  };

  system.defaults.NSGlobalDomain."com.apple.mouse.tapBehavior" = let
    tapToClick = 1;
  in
    tapToClick;

  system.defaults.universalaccess.closeViewScrollWheelToggle = true;

  system.defaults.CustomUserPreferences."com.apple.WindowManager" = {
    EnableTiledWindowMargins = 0;
  };

  system.defaults.dock = {
    persistent-apps = [];
    autohide = true;
  };

  power.sleep = {
    computer = "never";
    harddisk = "never";
    display = 20;
  };

  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToEscape = true;

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
