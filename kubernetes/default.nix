{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    kubernetes
    kubectl
  ];

  networking.hosts.nuc = ["10.0.0.2"];
  networking.hosts."10.0.0.2" = ["nuc"];
  networking.hosts.srv = ["10.0.0.4"];
  networking.hosts."10.0.0.4" = ["srv"];

  services.kubernetes = {
    masterAddress = "nuc";
    apiserverAddress = "https://nuc:6443";
    easyCerts = true;
    addons.dns.enable = true;
    clusterCidr = "10.2.0.0/16";
    kubelet.extraOpts = "--fail-swap-on=false";
  };
}
