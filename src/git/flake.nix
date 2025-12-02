{
  outputs = {self}: {
    home-module = {
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
          url."ssh://git@github.com/".insteadOf = "https://github.com/";
        };

        ignores = [
          ".DS_Store"
        ];
      };
    };
  };
}
