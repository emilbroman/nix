{
  flake,
  pkgs,
  zjstatus,
  ...
}: {
  imports = [./users];

  environment.systemPackages = [pkgs.fish];
  environment.shells = [pkgs.fish];

  nix.settings.experimental-features = "nix-command flakes";

  system.configurationRevision = flake.rev or flake.dirtyRev or null;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  home-manager.backupFileExtension = "old";
  home-manager.useGlobalPkgs = true;

  home-manager.extraSpecialArgs = {
    inherit zjstatus;
  };
}
