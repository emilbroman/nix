{...}: {
  services.caddy.virtualHosts."id.bb3.site".extraConfig = ''
    reverse_proxy http://127.0.0.1:7571
  '';

  systemd.services.turnstile = {
    description = "Turnstile";
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      ExecStart = "/home/emilbroman/code/turnstile/turnstile serve --db /var/lib/turnstile/turnstile.db --advertise-url https://id.bb3.site --domain bb3.site --ca /var/lib/turnstile/ca.crt --private-key-pem-file /var/lib/turnstile/ca.key";
      User = "emilbroman";
      Group = "wheel";

      StateDirectory = "turnstile";
      StateDirectoryMode = "0750";

      Restart = "always";
    };
  };
}
