{
  imports = [./default.nix];

  users.users.emilbroman = {
    home = "/home/emilbroman";
    isNormalUser = true;
    extraGroups = [
      "wheel" # Enable ‘sudo’.
      "docker"
    ];
  };
}
