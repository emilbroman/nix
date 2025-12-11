{
  networking.hostId = "4c7d5c8d";

  services.zfs.autoScrub.enable = true;

  boot.supportedFilesystems = ["zfs"];

  # boot.zfs.extraPools = ["tank"];
  # boot.zfs.devNodes = "/var/disk/by-id";

  # fileSystems."/srv/nfs" = {
  #   device = "tank/data/nfs";
  #   fsType = "zfs";
  #   options = ["nofail"];
  # };

  services.nfs.server.enable = true;
  services.nfs.server.exports = ''
    /srv/nfs       10.0.0.0/8(rw,sync,fsid=0,crossmnt,no_subtree_check,insecure) 127.0.0.0/8(rw,sync,fsid=0,crossmnt,no_subtree_check,insecure)
  '';
}
