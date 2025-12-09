{...}: {
  services.caddy.virtualHosts."id.bb3.site".extraConfig = ''
    reverse_proxy http://127.0.0.1:7571
  '';

  environment.etc."turnstile/turnstile.toml".text = ''
    [database]
    sqlite = "/var/lib/turnstile/turnstile.db"

    [server]
    advertise-url = "https://id.bb3.site"
    cookie-domain = "bb3.site"
    hostname = "127.0.0.1"

    [pki]
    "ca.crt" = "/var/lib/turnstile/ca.crt"
    "ca.key" = "/var/lib/turnstile/ca.key"
  '';

  systemd.services.turnstile = {
    description = "Turnstile";
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      ExecStart = "/home/emilbroman/code/turnstile/turnstile serve --config /etc/turnstile/turnstile.toml";
      User = "emilbroman";
      Group = "wheel";

      StateDirectory = "turnstile";
      StateDirectoryMode = "0750";

      Restart = "always";
    };
  };
}
