{pkgs, ...}: {
  networking.extraHosts = "10.0.0.2 kubernetes";

  environment.systemPackages = with pkgs; [
    kubernetes
    kubectl
  ];

  services.kubernetes = {
    masterAddress = "kubernetes";
    apiserverAddress = "https://kubernetes:6443";
    easyCerts = true;
    addons.dns.enable = true;
    clusterCidr = "10.2.0.0/16";
    kubelet.extraOpts = "--fail-swap-on=false";
  };
}
