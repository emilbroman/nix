{
  outputs = {self}: {
    common-module = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        kubernetes
        kubectl
      ];

      services.kubernetes = {
        masterAddress = "nuc.bb3.site";
        apiserverAddress = "https://nuc.bb3.site:6443";
        easyCerts = true;
        clusterCidr = "10.2.0.0/16";
        kubelet.extraOpts = "--fail-swap-on=false --root-dir=/var/lib/kubelet";
        kubelet.clusterDns = ["10.3.0.254"];
        flannel.enable = true;
      };
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
