{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    terminal-stack.url = ../../terminal-stack;

    kubernetes.url = ../../kubernetes;
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    terminal-stack,
    kubernetes,
  }: {
    nixosConfigurations."nuc" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      specialArgs = {
        secrets = import ./secrets.nix;
      };

      modules = [
        ./hardware-configuration.nix
        ./vpn.nix
        ./etcd-backups.nix
        kubernetes.master-module
        home-manager.nixosModules.home-manager
        terminal-stack.system-module
        ({
          pkgs,
          secrets,
          ...
        }: {
          nix.settings.experimental-features = "nix-command flakes";
          nix.settings.download-buffer-size = 524288000;

          boot.supportedFilesystems = ["nfs"];

          system.configurationRevision = self.rev or self.dirtyRev or null;

          networking.hostName = "nuc";
          networking.domain = "bb3.site";
          system.stateVersion = "24.11";

          systemd.network.links."10-lan0" = {
            matchConfig.MACAddress = "94:c6:91:a9:4f:e5";
            linkConfig.Name = "lan0";
          };
          networking.hosts."10.0.0.2" = ["nuc" "nuc.bb3.site"];

          nix.settings.trusted-users = ["emilbroman"];

          users.users.emilbroman = {
            name = "emilbroman";
            shell = pkgs.fish;
            home = "/home/emilbroman";
            isNormalUser = true;
            extraGroups = [
              "wheel" # Enable ‘sudo’.
            ];
          };

          home-manager.backupFileExtension = "old";
          home-manager.useGlobalPkgs = true;

          home-manager.users.emilbroman = {
            imports = [
              terminal-stack.home-module
            ];

            showHostnameInFishPrompt = true;

            home.stateVersion = "23.05";

            home.file.".hushlogin".text = "";

            programs.home-manager.enable = true;

            programs.fish.shellAliases.nix-rebuild = "sudo nixos-rebuild switch --flake ~/code/nix/src/machines/nuc";
          };

          # Use the systemd-boot EFI boot loader.
          boot.loader.systemd-boot.enable = true;
          boot.loader.efi.canTouchEfiVariables = true;

          networking.wireless.enable = true;

          time.timeZone = "Europe/Stockholm";

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

          services.caddy.virtualHosts."sunshine.bb3.site".extraConfig = ''
            @ext not client_ip private_ranges
            abort @ext
            forward_auth 127.0.0.1:7571 {
              uri /forward-auth
              copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
            }
            reverse_proxy https://10.0.0.4:47990 {
              header_up Authorization "Basic ${secrets.sunshine.basicAuth}"
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
