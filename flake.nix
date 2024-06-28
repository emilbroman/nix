{
  description = "Emil's Nix Flake for macOS";

  inputs = {
    nix-darwin.url = "github:LnL7/nix-darwin";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = { self, nix-darwin, home-manager }:
  let
    user = {
      username = "emilbroman";
      realname = "Emil Broman";
      email = "emil@emilbroman.me";
    };

    fish = import ./fish.nix;
    
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = with pkgs; [
        # OS packages
        skhd     # macOS keyboard shortcuts

        # Terminal development stack
        zellij    # Terminal multiplexer
        pkgs.fish # Shell
        yazi      # File explorer
        helix     # Editor

        # Terminal tools
        git
        ripgrep  # Fuzzy finder
        openssh  # SSH
        gnupg    # PGP

        # Language servers
        nil      # Nix
        marksman # Markdown
      ];
      environment.shells = [ pkgs.fish ];
      environment.variables.EDITOR = "hx";

      services.nix-daemon.enable = true;

      nix.settings.experimental-features = "nix-command flakes";

      homebrew.enable = true;
      homebrew.casks = [
        "wezterm"
        "docker"
      ];
      homebrew.onActivation = {
        autoUpdate = false;
        cleanup = "zap";
      };

      programs.fish = fish.systemConfig // {
        enable = true;
      };

      programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };

      system.configurationRevision = self.rev or self.dirtyRev or null;

      system.stateVersion = 4;

      nixpkgs.hostPlatform = "aarch64-darwin";

      system.defaults.NSGlobalDomain.InitialKeyRepeat = 10;
      system.defaults.NSGlobalDomain.KeyRepeat = 3;

      users.users.${user.username} = {
        name = user.username;
        home = "/Users/${user.username}";
        shell = pkgs.fish;
      };

      nix.settings.trusted-users = [ user.username ];
    };

    system = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${user.username} = { pkgs, ... }:
            let
              helix = import ./helix.nix;
            in
            {
              home.stateVersion = "23.05";

              programs.home-manager.enable = true;

              programs.fish = fish.userConfig // {
                enable = true;
              };

              programs.wezterm = {
                enable = true;
                extraConfig = import ./wezterm.lua.nix;
              };

              # Toggle WezTerm using F13
              home.file.".config/skhd/skhdrc".text = ''
                f13 [
                  "wezterm" : osascript -e 'tell application "System Events" to set visible of process "WezTerm" to false'
                  *         : osascript -e 'activate application "WezTerm"'
                ]
              '';

              programs.git = {
                enable = true;
                userName = user.realname;
                userEmail = user.email;
                signing.signByDefault = true;
                signing.key = null;

                extraConfig = {
                  init.defaultBranch = "main";
                };
              };

              home.file.".gnupg/gpg-agent.conf".text = ''
                pinentry-program ${pkgs.pinentry-curses}/bin/pinentry-curses
              '';

              home.file.".config/zellij/config.kdl".text = import ./zellij.kdl.nix;

              programs.helix = helix // {
                enable = true;
              };
            };
        }
      ];
    };
  in
  {
    darwinConfigurations."emils-mini" = system;
    darwinConfigurations."emils-macbook" = system;

    darwinPackages = system.pkgs;
  };
}
