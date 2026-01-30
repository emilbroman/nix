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
    nixosConfigurations."dev" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      specialArgs = {
        secrets = import ./secrets.nix;
      };

      modules = [
        ./hardware-configuration.nix
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

          networking.hostName = "dev";
          networking.domain = "vm.bb3.internal";
          system.stateVersion = "24.11";

          nix.settings.trusted-users = ["emilbroman"];

          security.pki.certificateFiles = [../../../bb3_root_ca.crt];

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

            programs.fish.shellAliases.nix-rebuild = "sudo nixos-rebuild switch --flake ~/code/nix/src/machines/dev";
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
        })
      ];
    };
  };
}
