{
  pkgs,
  zjstatus,
  ...
}: {
  imports = [
    ./fish.nix
    ./helix.nix
  ];

  home.stateVersion = "23.05";

  home.packages = with pkgs; [
    # Terminal development stack
    zellij # Terminal multiplexer
    yazi # File explorer
    helix # Editor

    # Terminal tools
    git
    ripgrep # Fuzzy finder
    openssh # SSH
    gnupg # PGP
    wget
    pstree

    # Nix
    nil
    alejandra

    # Markdown
    marksman

    # TypeScript
    pkgs.nodePackages.typescript-language-server
    pkgs.nodePackages.prettier
  ];

  programs.home-manager.enable = true;

  programs.wezterm = {
    enable = true;
    extraConfig = import ./wezterm.lua.nix;
  };

  programs.git = {
    enable = true;
    userName = "Emil Broman";
    userEmail = "emil@emilbroman.me";
    signing.signByDefault = true;
    signing.key = null;

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      fetch.prunt = true;
      diff.colorMoved = "zebra";
      push.autoSetupRemote = true;
      rerere.enabled = true;
    };
  };

  home.file.".gnupg/gpg-agent.conf".text = ''
    pinentry-program ${pkgs.pinentry-curses}/bin/pinentry-curses
  '';

  home.file.".config/zellij/config.kdl".text = (import ./zellij.nix).config;
  home.file.".config/zellij/layouts/default.kdl".text = (import ./zellij.nix).defaultLayout {zjstatus = zjstatus;};

  home.file.".hushlogin".text = "";

  programs.ssh.enable = true;

  programs.ssh.matchBlocks.home = {
    host = "home";
    hostname = "home.emilbroman.me";
  };

  programs.ssh.matchBlocks.nuc = {
    host = "nuc";
    hostname = "10.0.0.2";
  };

  programs.ssh.matchBlocks.mini = {
    host = "mini";
    hostname = "10.0.0.3";
  };

  programs.ssh.matchBlocks.srv = {
    host = "srv";
    hostname = "10.0.0.4";
  };

  programs.ssh.matchBlocks.macbook = {
    host = "macbook";
    hostname = "10.0.0.6";
  };
}
