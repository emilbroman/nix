{
  outputs = {self}: {
    common-module = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        kubernetes
        kubectl
      ];

      services.kubernetes = {
        masterAddress = "10.0.0.2";
        apiserverAddress = "https://10.0.0.2:6443";
        easyCerts = true;
        clusterCidr = "10.2.0.0/16";
        kubelet.extraOpts = "--fail-swap-on=false --root-dir=/var/lib/kubelet";
        kubelet.clusterDns = ["10.3.0.254"];
        flannel.enable = true;
      };

      virtualisation.containerd.settings.plugins."io.containerd.grpc.v1.cri".registry.configs."cr.bb3.site".tls = {
        cert_file = "/var/lib/containerd/io.containerd.grpc.v1.cri/registries/cr.bb3.site/tls.crt";
        key_file = "/var/lib/containerd/io.containerd.grpc.v1.cri/registries/cr.bb3.site/tls.key";
        ca_file = "/var/lib/containerd/io.containerd.grpc.v1.cri/registries/cr.bb3.site/ca.crt";
      };

      networking.hosts."10.0.0.4" = ["srv" "srv.bb3.site"];
      networking.hosts."10.0.0.2" = ["nuc" "nuc.bb3.site"];
    };

    master-module = {
      imports = [
        self.common-module
      ];

      services.kubernetes = {
        roles = ["master"];
        apiserver = {
          securePort = 6443;
          advertiseAddress = "10.0.0.2";
          allowPrivileged = true;
          serviceClusterIpRange = "10.3.0.0/24";
          extraSANs = ["nuc" "nuc.bb3.site"];
        };
      };
    };

    node-module = {
      imports = [
        self.common-module
      ];

      services.kubernetes = {
        roles = ["node"];
        kubelet.kubeconfig.server = "https://nuc.bb3.site:6443";
      };
    };
  };
}
