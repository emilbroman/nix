{
  outputs = {self}: {
    system-module = {
      programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };
    };

    home-module = {pkgs, ...}: {
      programs.gpg = {
        enable = true;
        mutableKeys = true;
        mutableTrust = true;
      };

      home.file.".gnupg/gpg-agent.conf".text = ''
        pinentry-program ${pkgs.pinentry-curses}/bin/pinentry-curses
      '';
    };
  };
}
