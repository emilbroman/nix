{
  pkgs,
  user,
  zjstatus,
  ...
}: let
  fish = import ./fish.nix;
in {
  home.stateVersion = "23.05";

  programs.home-manager.enable = true;

  programs.fish =
    fish.userConfig
    // {
      enable = true;
    };

  programs.wezterm = {
    enable = true;
    extraConfig = import ./wezterm.lua.nix;
  };

  programs.git = {
    enable = true;
    userName = user.realname;
    userEmail = user.email;
    signing.signByDefault = true;
    signing.key = null;

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      fetch.prunt = true;
      diff.colorMoved = "zebra";
      push.autoSetupRemote = true;
    };
  };

  home.file.".gnupg/gpg-agent.conf".text = ''
    pinentry-program ${pkgs.pinentry-curses}/bin/pinentry-curses
  '';

  home.file.".config/zellij/config.kdl".text = (import ./zellij.nix).config;
  home.file.".config/zellij/layouts/default.kdl".text = (import ./zellij.nix).defaultLayout {zjstatus = zjstatus;};

  home.file.".hushlogin".text = "";

  programs.helix =
    (import ./helix.nix)
    // {
      enable = true;
    };

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
}
