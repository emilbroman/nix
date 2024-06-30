{pkgs, ...}: {
  users.users.emilbroman = {
    name = "emilbroman";
    shell = pkgs.fish;
  };

  home-manager.users.emilbroman = {
    imports = [./home.nix];
  };
}
