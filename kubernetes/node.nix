{
  imports = [
    ./default.nix
  ];

  services.kubernetes = {
    roles = ["node"];
    kubelet.kubeconfig.server = "https://kubernetes:6443";
  };
}
