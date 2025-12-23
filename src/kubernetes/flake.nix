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

      environment.etc."containerd/certs.d/cr.bb3.site/hosts.toml".text = ''
        server = "https://cr.bb3.site"
        [host."https://cr.bb3.site"]
          capabilities = ["pull", "resolve", "push"]
          ca = "/var/lib/containerd/io.containerd.grpc.v1.cri/registries/cr.bb3.site/ca.crt"
          client = [[
            "/var/lib/containerd/io.containerd.grpc.v1.cri/registries/cr.bb3.site/tls.crt",
            "/var/lib/containerd/io.containerd.grpc.v1.cri/registries/cr.bb3.site/tls.key",
          ]]
      '';

      virtualisation.containerd.settings.plugins."io.containerd.grpc.v1.cri".registry.config_path = "/etc/containerd/certs.d";

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
