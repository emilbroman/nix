{
  outputs = {self}: {
    home-module = {
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
    };
  };
}
