{
  description = "Emil's Nix Flake for macOS & Linux";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    home-manager.url = "github:nix-community/home-manager";
    zjstatus.url = "https://github.com/dj95/zjstatus/releases/latest/download/zjstatus.wasm";
    zjstatus.flake = false;
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, zjstatus }:
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
        wget

        # Language servers
        nil      # Nix
        marksman # Markdown
      ];
      environment.shells = [ pkgs.fish ];
      environment.variables.EDITOR = "hx";
      environment.variables.COLORTERM = "truecolor";

      nix.settings.experimental-features = "nix-command flakes";

      programs.fish = fish.systemConfig // {
        enable = true;
      };

      programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };

      system.configurationRevision = self.rev or self.dirtyRev or null;

      users.users.${user.username} = {
        name = user.username;
        shell = pkgs.fish;
      };

      nix.settings.trusted-users = [ user.username ];
      
      home-manager.backupFileExtension = "old";
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${user.username} = { pkgs, ... }: {
        home.stateVersion = "23.05";

        programs.home-manager.enable = true;

        programs.fish = fish.userConfig // {
          enable = true;
        };

        programs.wezterm = {
          enable = true;
          extraConfig = import ./wezterm.lua.nix;
        };

        programs.git = {
          enable = true;
          userName = user.realname;
          userEmail = user.email;
          signing.signByDefault = true;
          signing.key = null;

          extraConfig = {
            init.defaultBranch = "main";
            pull.rebase = true;
            fetch.prunt = true;
            diff.colorMoved = "zebra";
            push.autoSetupRemote = true;
          };
        };

        home.file.".gnupg/gpg-agent.conf".text = ''
          pinentry-program ${pkgs.pinentry-curses}/bin/pinentry-curses
        '';

        home.file.".config/zellij/config.kdl".text = (import ./zellij.nix).config;
        home.file.".config/zellij/layouts/default.kdl".text = (import ./zellij.nix).defaultLayout { inherit zjstatus; };

        programs.helix = (import ./helix.nix) // {
          enable = true;
        };

        programs.ssh.enable = true;

        programs.ssh.matchBlocks.home = {
          host = "home";
          hostname = "home.emilbroman.me";
        };

        programs.ssh.matchBlocks.nuc = {
          host = "nuc";
          hostname = "10.0.0.2";
        };

        programs.ssh.matchBlocks.mini = {
          host = "mini";
          hostname = "10.0.0.3";
        };
      };
    };

    darwinConfiguration = { pkgs, ... }: {
      system.stateVersion = 4;

      services.nix-daemon.enable = true;
      nixpkgs.hostPlatform = "aarch64-darwin";

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
        skhd     # macOS keyboard shortcuts
      ];

      users.users.${user.username}.home = "/Users/${user.username}";

      system.defaults.NSGlobalDomain.InitialKeyRepeat = 10;
      system.defaults.NSGlobalDomain.KeyRepeat = 3;

      home-manager.users.${user.username} = {
        # Toggle WezTerm using F13
        home.file.".config/skhd/skhdrc".text = ''
          f13 [
            "wezterm" : osascript -e 'tell application "System Events" to set visible of process "WezTerm" to false'
            *         : osascript -e 'activate application "WezTerm"'
          ]
        '';
      };
    };

    linuxConfiguration = { pkgs, ...}: {
      # Use the systemd-boot EFI boot loader.
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      networking.hostName = "nuc";
      networking.wireless.enable = true;

      time.timeZone = "Europe/Stockholm";

      virtualisation.docker.enable = true;
      environment.systemPackages = with pkgs; [
        docker
      ];

      # Select internationalisation properties.
      i18n.defaultLocale = "en_US.UTF-8";
      console = {
        font = "Lat2-Terminus16";
        keyMap = "us";
      };

      # Define a user account. Don't forget to set a password with ‘passwd’.
      users.users.${user.username} = {
        isNormalUser = true;
        extraGroups = [
          "wheel" # Enable ‘sudo’.
          "docker"
        ];
      };

      # Enable the OpenSSH daemon.
      services.openssh.enable = true;

      # Disable firewall (use firewall in router).
      networking.firewall.enable = false;

      system.stateVersion = "24.11";
    };
  in
  {
    darwinConfigurations."emils-mini" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        home-manager.darwinModules.home-manager
        darwinConfiguration
      ];
    };

    darwinConfigurations."emils-macbook" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        home-manager.darwinModules.home-manager
        darwinConfiguration
      ];
    };

    nixosConfigurations."nuc" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        configuration
        /etc/nixos/hardware-configuration.nix
        home-manager.nixosModules.home-manager
        linuxConfiguration
      ];
    };
  };
}
