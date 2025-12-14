{pkgs, ...}: {
  networking.hostId = "4c7d5c8d";

  boot.supportedFilesystems = ["zfs"];
  boot.zfs.forceImportAll = true;
  boot.zfs.extraPools = ["tank"];

  services.zfs.autoScrub.enable = true;

  services.nfs.server.enable = true;
  services.nfs.server.exports = ''
    /srv/nfs       10.0.0.0/8(rw,sync,fsid=0,crossmnt,no_subtree_check,insecure,no_root_squash) 127.0.0.0/8(rw,sync,fsid=0,crossmnt,no_subtree_check,insecure,no_root_squash)
  '';

  systemd.services."zfs-snapshot" = {
    description = "Create timestamped ZFS snapshots";
    serviceConfig = {
      Type = "oneshot";

      User = "root";
      Group = "root";
      CapabilityBoundingSet = ["CAP_SYS_ADMIN"];
      AmbientCapabilities = ["CAP_SYS_ADMIN"];

      ExecStart = ''
        /bin/sh -c '${pkgs.zfs}/bin/zfs snapshot "tank/data/nfs@$(date --utc +%%Y-%%m-%%d_%%H)"'
      '';
    };
  };

  systemd.timers."zfs-snapshot" = {
    description = "Run periodic ZFS snapshots";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "*:5";
      Persistent = true;
    };
  };
}
