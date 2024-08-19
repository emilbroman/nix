{
  imports = [./default.nix];

  users.users.emilbroman = {
    home = "/Users/emilbroman";
  };

  homebrew.casks = [
    "figma"
  ];
}
