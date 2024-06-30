{pkgs, ...}: {
  users.users.emilbroman = {
    name = "emilbroman";
    shell = pkgs.fish;
    home = "/Users/emilbroman";
    # isNormalUser = true;
    # extraGroups = [
    #   "wheel" # Enable ‘sudo’.
    #   "docker"
    # ];
  };

  home-manager.users.emilbroman = {
    imports = [./home.nix];
  };
}
