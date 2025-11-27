let
  theme = (import ./themes.nix).current;
in
  {
    pkgs,
    zjstatus,
    ...
  }: {
    imports = [
      ./fish.nix
      ./helix.nix
      ./zed.nix
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
      wget
      pstree
      watch
      jq
      moreutils

      # Nix
      nil
      alejandra

      # Markdown
      marksman

      # TypeScript
      nodePackages.typescript-language-server

      # Typst
      tinymist

      # Cloud Management
      awscli
      google-cloud-sdk
    ];

    programs.home-manager.enable = true;

    programs.wezterm = {
      enable = true;
      extraConfig = (import ./wezterm.lua.nix) {
        inherit pkgs;
        theme = theme.wezterm;
      };
    };

    programs.git = {
      enable = true;
      signing.signByDefault = true;
      signing.key = null;

      settings = {
        user.name = "Emil Broman";
        user.email = "emil@emilbroman.me";
        init.defaultBranch = "main";
        pull.rebase = true;
        fetch.prunt = true;
        diff.colorMoved = "zebra";
        push.autoSetupRemote = true;
        rerere = {
          enabled = true;
          autoupdate = true;
        };
      };

      ignores = [
        ".DS_Store"
      ];
    };

    programs.gpg = {
      enable = true;
      mutableKeys = true;
      mutableTrust = true;
    };

    home.file.".gnupg/gpg-agent.conf".text = ''
      pinentry-program ${pkgs.pinentry-curses}/bin/pinentry-curses
    '';

    home.file.".config/zellij/config.kdl".text = (import ./zellij.nix).config {theme = theme.zellij;};
    home.file.".config/zellij/layouts/default.kdl".text = (import ./zellij.nix).defaultLayout {
      zjstatus = zjstatus;
      theme = theme.zellij;
    };

    home.file.".hushlogin".text = "";

    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;

      matchBlocks.home = {
        host = "home";
        hostname = "home.emilbroman.me";
      };

      matchBlocks.nuc = {
        host = "nuc";
        hostname = "10.0.0.2";
      };

      matchBlocks.srv = {
        host = "srv";
        hostname = "10.0.0.4";
      };

      matchBlocks.mini = {
        host = "mini";
        hostname = "10.0.0.5";
      };

      matchBlocks.macbook = {
        host = "macbook";
        hostname = "10.0.0.6";
      };
    };
  }
