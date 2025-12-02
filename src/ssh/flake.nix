{
  outputs = {self}: {
    home-module = {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;

        matchBlocks.home = {
          host = "bb3";
          hostname = "bb3.site";
        };

        matchBlocks.nuc = {
          host = "nuc";
          hostname = "nuc.bb3.site";
        };

        matchBlocks.srv = {
          host = "srv";
          hostname = "srv.bb3.site";
        };

        matchBlocks.mini = {
          host = "mini";
          hostname = "mini.bb3.site";
        };

        matchBlocks.macbook = {
          host = "macbook";
          hostname = "macbook.bb3.site";
        };
      };
    };
  };
}
