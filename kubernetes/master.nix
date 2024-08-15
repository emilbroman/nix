{
  imports = [
    ./default.nix
  ];

  services.kubernetes = {
    roles = ["master"];
    apiserver = {
      securePort = 6443;
      advertiseAddress = "10.0.0.2";
    };
  };
}
