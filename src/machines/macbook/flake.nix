{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    apps.url = ./apps;
    tv4.url = ./tv4;
    skyr.url = ./skyr;

    mac.url = ../../mac;
    terminal-stack.url = ../../terminal-stack;
    agents.url = ../../agents;
    theme.url = ../../themes/dark;
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nix-darwin,
    apps,
    tv4,
    skyr,
    mac,
    terminal-stack,
    agents,
    theme,
  }: {
    darwinConfigurations."emils-macbook" = nix-darwin.lib.darwinSystem {
      modules = [
        (
          {
            pkgs,
            lib,
            config,
            ...
          }: {
            nix.settings.experimental-features = "nix-command flakes";
            nix.settings.trusted-users = ["emilbroman"];

            system.configurationRevision = self.rev or self.dirtyRev or null;

            nixpkgs.hostPlatform = "aarch64-darwin";
            networking.hostName = "emils-macbook";
            ids.gids.nixbld = 350;

            system.stateVersion = 4;
            system.primaryUser = "emilbroman";

            security.pki.installCACerts = true;
            security.pki.certificateFiles = [../../../bb3_root_ca.crt];

            home-manager.backupFileExtension = "old";
            home-manager.useGlobalPkgs = true;

            users.users.emilbroman = {
              name = "emilbroman";
              shell = pkgs.fish;
              home = "/Users/emilbroman";
            };

            home-manager.users.emilbroman = {
              imports = [
                (terminal-stack.home-module {inherit theme;})
                (apps.home-module {inherit theme;})
                (agents.home-module {inherit theme;})
                tv4.home-module
                skyr.home-module
              ];

              programs.codex.settings.projects."${config.users.users.emilbroman.home}/code/skyr".trust_level = "trusted";
              programs.codex.settings.projects."${config.users.users.emilbroman.home}/code/skyr-constructs/Ingress".trust_level = "trusted";
              programs.codex.settings.projects."${config.users.users.emilbroman.home}/code/skyr-constructs/IAM".trust_level = "trusted";

              home.stateVersion = "23.05";

              programs.home-manager.enable = true;

              programs.fish.functions.nix-rebuild = ''
                sudo darwin-rebuild switch --flake ~/code/nix/src/machines/macbook
              '';

              programs.fish.functions.nix-upgrade = ''
                sudo nix flake update --flake ~/code/nix/src/machines/macbook
                nix-rebuild
              '';

              home.packages = with pkgs; [
                # Cloud Management
                awscli2
                google-cloud-sdk
              ];

              programs.gpg.pinentryPkg = pkgs.pinentry_mac;
            };
          }
        )
        home-manager.darwinModules.home-manager
        (apps.system-module {user = "emilbroman";})
        mac.system-module
        terminal-stack.system-module
        agents.system-module
        tv4.system-module
      ];
    };
  };
}
