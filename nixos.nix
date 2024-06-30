{pkgs, ...}: {
  imports = [./configuration.nix];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Disable firewall (use firewall in router).
  networking.firewall.enable = false;

  system.stateVersion = "24.11";

  home-manager.sharedModules = [
    {
      programs.fish.shellAliases.nix-rebuild = "sudo nixos-rebuild switch --flake ~/code/nix --impure";
    }
  ];
}
