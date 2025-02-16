{
  imports = [
    ./default.nix
  ];

  services.kubernetes = {
    roles = ["node"];
    kubelet.kubeconfig.server = "https://nuc:6443";
  };
}
