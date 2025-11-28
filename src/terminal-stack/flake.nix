{
  inputs = {
    fish.url = ../fish;
    helix.url = ../helix;
    zellij.url = ../zellij;
    gpg.url = ../gpg;
    git.url = ../git;
    ssh.url = ../ssh;
    dark-theme.url = ../themes/dark;
  };

  outputs = {
    self,
    fish,
    helix,
    zellij,
    gpg,
    git,
    ssh,
    dark-theme,
  }: {
    theme = dark-theme;

    system-module = {
      imports = [
        fish.system-module
        gpg.system-module
      ];
    };

    home-module = {pkgs, ...}: {
      imports = [
        (fish.home-module {theme = self.theme;})
        (helix.home-module {theme = self.theme;})
        (zellij.home-module {theme = self.theme;})
        gpg.home-module
        git.home-module
        ssh.home-module
      ];

      home.packages = with pkgs; [
        yazi
        ripgrep
        wget
        pstree
        watch
        jq
        moreutils
        tree
      ];
    };
  };
}
