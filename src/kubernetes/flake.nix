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
        addons.dns.enable = true;
        clusterCidr = "10.2.0.0/16";
        kubelet.extraOpts = "--fail-swap-on=false";
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
