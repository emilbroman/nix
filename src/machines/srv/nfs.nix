{
  fileSystems."/nfs/pvc" = {
    device = "/var/lib/pvc";
    options = ["bind"];
    fsType = "none";
  };

  services.nfs.server.enable = true;
  services.nfs.server.exports = ''
    /nfs       10.0.0.0/8(rw,sync,fsid=0,crossmnt,no_subtree_check,insecure) 127.0.0.0/8(rw,sync,fsid=0,crossmnt,no_subtree_check,insecure)
    /nfs/pvc   10.0.0.0/8(rw,sync,no_subtree_check,insecure) 127.0.0.0/8(rw,sync,no_subtree_check,insecure)
  '';
}
