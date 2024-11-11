{
  imports = [./default.nix];

  users.users.emilbroman = {
    home = "/Users/emilbroman";
  };

  homebrew.casks = [
    "figma"
    "wezterm"
    "docker"
    "google-chrome"
    "slack"
    "mongodb-compass"
  ];
}
