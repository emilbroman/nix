{
  outputs = {self}: {
    home-module = {lib, ...}: {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;

        matchBlocks =
          {
            cp = {
              host = "cp";
              hostname = "cp.bb3.internal";
              extraOptions.StrictHostKeyChecking = "no";
              extraOptions.UserKnownHostsFile = "/dev/null";
              user = "root";
            };

            dev = {
              host = "dev";
              hostname = "dev.vm.bb3.internal";
              user = "emilbroman";
            };

            tower = {
              host = "tower";
              hostname = "tower.hw.bb3.internal";
              user = "root";
            };
          }
          // builtins.listToAttrs (map (i: {
            name = "tc${toString i}";
            value.host = "tc${toString i}";
            value.hostname = "tc${toString i}.hw.bb3.internal";
            value.user = "root";
          }) (lib.lists.range 1 3))
          // builtins.listToAttrs (map (i: {
            name = "cp${toString i}";
            value.host = "cp${toString i}";
            value.hostname = "cp${toString i}.vm.bb3.internal";
            value.user = "root";
          }) (lib.lists.range 1 3))
          // builtins.listToAttrs (map (i: {
            name = "node${toString i}";
            value.host = "node${toString i}";
            value.hostname = "node${toString i}.vm.bb3.internal";
            value.user = "root";
          }) (lib.lists.range 1 4));
      };
    };
  };
}
