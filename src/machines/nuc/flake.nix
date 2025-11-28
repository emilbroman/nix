{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    terminal-stack.url = ../../terminal-stack;
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    terminal-stack,
  }: {
    nixosConfigurations."nuc" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hardware-configuration.nix
        ../../../kubernetes/master.nix
        home-manager.nixosModules.home-manager
        terminal-stack.system-module
        ({pkgs, ...}: {
          nix.settings.experimental-features = "nix-command flakes";
          nix.settings.download-buffer-size = 524288000;

          system.configurationRevision = self.rev or self.dirtyRev or null;

          networking.hostName = "nuc";
          system.stateVersion = "24.11";

          nix.settings.trusted-users = ["emilbroman"];

          users.users.emilbroman = {
            name = "emilbroman";
            shell = pkgs.fish;
            home = "/home/emilbroman";
            isNormalUser = true;
            extraGroups = [
              "wheel" # Enable ‘sudo’.
              "docker"
            ];
          };

          home-manager.backupFileExtension = "old";
          home-manager.useGlobalPkgs = true;

          home-manager.users.emilbroman = {
            imports = [
              terminal-stack.home-module
            ];

            home.stateVersion = "23.05";

            programs.home-manager.enable = true;

            programs.fish.shellAliases.nix-rebuild = "sudo nixos-rebuild switch --flake ~/code/nix/src/machines/nuc";
          };

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

          services.caddy.enable = true;

          services.caddy.virtualHosts."home.emilbroman.me".extraConfig = ''
            reverse_proxy http://10.0.0.4:30080
          '';

          services.caddy.virtualHosts."ollama.home.emilbroman.me".extraConfig = ''
            basic_auth {
              emil $2y$10$eViJe8Yioo.Qb.oPSohXm.A.kB0GI3pBEahtGkPM/d0DwLD.crApK
            }

            reverse_proxy http://10.0.0.4:11434
          '';

          services.caddy.virtualHosts."kvm.home.emilbroman.me".extraConfig = ''
            reverse_proxy https://10.0.0.3 {
              transport http {
                tls_insecure_skip_verify
              }
            }
          '';

          services.caddy.virtualHosts."omada.home.emilbroman.me".extraConfig = ''
            reverse_proxy https://localhost:8043 {
              transport http {
                tls_insecure_skip_verify
              }
            }
          '';

          services.caddy.virtualHosts."sunshine.home.emilbroman.me".extraConfig = ''
            reverse_proxy https://10.0.0.4:47990 {
              transport http {
                tls_insecure_skip_verify
              }
            }
          '';
        })
      ];
    };
  };
}
