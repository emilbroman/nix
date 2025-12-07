{
  pkgs,
  secrets,
  ...
}: {
  services.openvpn.servers.homenet = {
    autoStart = true;

    config = ''
      port 1194
      proto udp
      dev tun

      user nobody
      group nogroup

      dh   /var/lib/turnstile/dh.pem
      ca   /var/lib/turnstile/ca.crt
      cert /var/lib/turnstile/server.crt
      key  /var/lib/turnstile/server.key

      server 10.8.0.0 255.255.255.0
      keepalive 10 120
      persist-key
      persist-tun
      topology subnet

      push "route 10.0.0.0 255.255.255.0"
      push "dhcp-option DNS 10.0.0.2"

      tls-version-min 1.2
      cipher AES-256-GCM
      data-ciphers AES-256-GCM:AES-128-GCM:CHACHA20-POLY1305
      data-ciphers-fallback AES-256-GCM

      verb 3
    '';
  };
}
