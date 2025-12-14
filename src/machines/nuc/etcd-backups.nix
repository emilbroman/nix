{pkgs, ...}: {
  fileSystems."/mnt/etcd" = {
    device = "srv.bb3.site:/srv/nfs/etcd";
    fsType = "nfs";
  };

  systemd.services.etcd-snapshot = {
    description = "etcd snapshot to NFS";
    unitConfig = {
      RequiresMountsFor = ["/mnt/etcd"];
      After = ["network-online.target"];
    };
    serviceConfig = {
      Type = "oneshot";
    };
    script = ''
      set -euo pipefail
      ts="$(date -u +%Y-%m-%dT%H%M%SZ)"
      out="/mnt/etcd/snapshot-$ts.db"
      mkdir -p "$(dirname "$out")"

      ${pkgs.etcd}/bin/etcdctl \
        --endpoints=https://etcd.local:2379 \
        --cacert=/var/lib/kubernetes/secrets/ca.pem \
        --cert=/var/lib/kubernetes/secrets/etcd.pem \
        --key=/var/lib/kubernetes/secrets/etcd-key.pem \
        snapshot save "$out"

      ${pkgs.etcd}/bin/etcdctl snapshot status "$out" --write-out=table

      find /mnt/etcd -name 'snapshot-*.db' -mtime +30 -delete
    '';
  };

  systemd.timers.etcd-snapshot = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "hourly";
      RandomizedDelaySec = "10m";
      Persistent = true;
    };
  };
}
