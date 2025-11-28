{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    mac.url = ../../mac;
    terminal-stack.url = ../../terminal-stack;
  };

  outputs = {
    self,
    nixpkgs,
    nix-darwin,
    home-manager,
    mac,
    terminal-stack,
  }: {
    darwinConfigurations."emils-mini" = nix-darwin.lib.darwinSystem {
      modules = [
        ({pkgs, ...}: {
          nix.settings.experimental-features = "nix-command flakes";
          nix.settings.trusted-users = ["emilbroman"];

          system.configurationRevision = self.rev or self.dirtyRev or null;

          nixpkgs.hostPlatform = "aarch64-darwin";
          networking.hostName = "emils-mini";
          ids.gids.nixbld = 30000;

          system.stateVersion = 4;
          system.primaryUser = "emilbroman";

          home-manager.backupFileExtension = "old";
          home-manager.useGlobalPkgs = true;

          users.users.emilbroman = {
            name = "emilbroman";
            shell = pkgs.fish;
            home = "/Users/emilbroman";
          };

          home-manager.users.emilbroman = {
            imports = [
              terminal-stack.home-module
            ];

            home.stateVersion = "23.05";

            programs.home-manager.enable = true;

            programs.fish.functions.nix-rebuild = ''
              sudo darwin-rebuild switch --flake ~/code/nix/src/machines/mini
            '';
          };
        })
        home-manager.darwinModules.home-manager
        mac.system-module
        terminal-stack.system-module
      ];
    };
  };
}
