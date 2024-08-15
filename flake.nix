{
  description = "Emil's Nix Flake for macOS & Linux";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

    nix-darwin.url = "github:LnL7/nix-darwin";

    home-manager.url = "github:nix-community/home-manager";

    zjstatus.url = "https://github.com/dj95/zjstatus/releases/latest/download/zjstatus.wasm";
    zjstatus.flake = false;
  };

  outputs = {
    self,
    nixpkgs,
    nixos-wsl,
    nix-darwin,
    home-manager,
    zjstatus,
  }: let
    specialArgs = {
      inherit zjstatus;
      flake = self;
    };
  in {
    darwinConfigurations."emils-macbook" = nix-darwin.lib.darwinSystem {
      inherit specialArgs;
      modules = [
        {
          nixpkgs.hostPlatform = "aarch64-darwin";
        }
        home-manager.darwinModules.home-manager
        ./darwin.nix
      ];
    };

    darwinConfigurations."emils-mini" = nix-darwin.lib.darwinSystem {
      inherit specialArgs;
      modules = [
        {
          nixpkgs.hostPlatform = "aarch64-darwin";
        }
        home-manager.darwinModules.home-manager
        ./darwin.nix
      ];
    };

    nixosConfigurations."nuc" = nixpkgs.lib.nixosSystem {
      inherit specialArgs;
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        ./users/nixos.nix
        ./kubernetes/master.nix
        /etc/nixos/hardware-configuration.nix
        home-manager.nixosModules.home-manager
        {
          networking.hostName = "nuc";
          system.stateVersion = "24.11";

          # Use the systemd-boot EFI boot loader.
          boot.loader.systemd-boot.enable = true;
          boot.loader.efi.canTouchEfiVariables = true;

          networking.wireless.enable = true;

          time.timeZone = "Europe/Stockholm";

          virtualisation.docker.enable = true;

          # Select internationalisation properties.
          i18n.defaultLocale = "en_US.UTF-8";
          console = {
            font = "Lat2-Terminus16";
            keyMap = "us";
          };

          # Enable the OpenSSH daemon.
          services.openssh.enable = true;

          # Disable firewall (use firewall in router).
          networking.firewall.enable = false;

          home-manager.sharedModules = [
            {
              programs.fish.shellAliases.nix-rebuild = "sudo nixos-rebuild switch --flake ~/code/nix --impure";
            }
          ];
        }
      ];
    };

    nixosConfigurations."srv" = nixpkgs.lib.nixosSystem {
      inherit specialArgs;
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        ./users/nixos.nix
        ./kubernetes/node.nix
        nixos-wsl.nixosModules.default
        home-manager.nixosModules.home-manager
        {
          system.stateVersion = "24.05";
          wsl.enable = true;
          wsl.defaultUser = "emilbroman";
          wsl.wslConf.network.generateHosts = false;
          networking.hostName = "srv";
          services.openssh.enable = true;

          virtualisation.docker.enable = true;

          home-manager.sharedModules = [
            {
              programs.fish.shellAliases.nix-rebuild = "sudo nixos-rebuild switch --flake ~/code/nix";
            }
          ];
        }
      ];
    };
  };
}
