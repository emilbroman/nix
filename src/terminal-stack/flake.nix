{
  inputs = {
    fish.url = ../fish;
    helix.url = ../helix;
    zellij.url = ../zellij;
    gpg.url = ../gpg;
    git.url = ../git;
    ssh.url = ../ssh;
    kubectl.url = ../kubectl;
  };

  outputs = {
    self,
    fish,
    helix,
    zellij,
    gpg,
    git,
    ssh,
    kubectl,
  }: {
    system-module = {
      imports = [
        fish.system-module
        gpg.system-module
      ];
    };

    home-module = {theme}: {pkgs, ...}: {
      imports = [
        (fish.home-module {inherit theme;})
        (helix.home-module {inherit theme;})
        (zellij.home-module {inherit theme;})
        gpg.home-module
        git.home-module
        ssh.home-module
        kubectl.home-module
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
        gh
      ];
    };
  };
}
