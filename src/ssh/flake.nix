{
  outputs = {self}: {
    home-module = {lib, ...}: {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;

        settings =
          {
            cp = {
              HostName = "cp.bb3.internal";
              StrictHostKeyChecking = "no";
              UserKnownHostsFile = "/dev/null";
              User = "root";
            };

            dev = {
              HostName = "dev.vm.bb3.internal";
              User = "emilbroman";
            };

            tower = {
              HostName = "tower.hw.bb3.internal";
              User = "root";
            };
          }
          // builtins.listToAttrs (map (i: {
            name = "tc${toString i}";
            value.HostName = "tc${toString i}.hw.bb3.internal";
            value.User = "root";
          }) (lib.lists.range 1 3))
          // builtins.listToAttrs (map (i: {
            name = "cp${toString i}";
            value.HostName = "cp${toString i}.vm.bb3.internal";
            value.User = "root";
          }) (lib.lists.range 1 3))
          // builtins.listToAttrs (map (i: {
            name = "node${toString i}";
            value.HostName = "node${toString i}.vm.bb3.internal";
            value.User = "root";
          }) (lib.lists.range 1 4));
      };
    };
  };
}
