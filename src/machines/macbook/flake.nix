{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    apps.url = ./apps;

    mac.url = ../../mac;
    terminal-stack.url = ../../terminal-stack;
    agents.url = ../../agents;
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nix-darwin,
    apps,
    mac,
    terminal-stack,
    agents,
  }: {
    darwinConfigurations."emils-macbook" = nix-darwin.lib.darwinSystem {
      modules = [
        (
          {pkgs, ...}: {
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

            nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) ["claude-code"];

            environment.systemPackages = with pkgs; [
              claude-code
            ];

            home-manager.users.emilbroman = {
              imports = [
                terminal-stack.home-module
                (apps.home-module {theme = terminal-stack.theme;})
                agents.home-module
              ];

              home.stateVersion = "23.05";

              programs.home-manager.enable = true;

              programs.fish.functions.nix-rebuild = ''
                sudo darwin-rebuild switch --flake ~/code/nix/src/machines/macbook
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
      ];
    };
  };
}
