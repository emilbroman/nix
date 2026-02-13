{
  outputs = {self}: {
    system-module = {
      programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };
    };

    home-module = {
      config,
      lib,
      pkgs,
      ...
    }: let
      cfg = config.programs.gpg;
    in {
      options.programs.gpg.pinentryPkg = lib.mkOption {
        type = lib.types.package;
        default = pkgs.pinentry-curses;
        description = "Pinentry package used by gpg-agent.";
      };

      config = {
        programs.gpg = {
          enable = true;
          mutableKeys = true;
          mutableTrust = true;
        };

        home.file.".gnupg/gpg-agent.conf".text = ''
          pinentry-program ${lib.getExe cfg.pinentryPkg}
        '';
      };
    };
  };
}
