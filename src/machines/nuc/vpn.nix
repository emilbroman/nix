{
  services.openvpn.servers.homenet = {
    autoStart = true;

    config = ''
      port 1194
      proto udp
      dev tun

      user nobody
      group nogroup

      dh   /etc/openvpn/dh.pem
      ca   /etc/openvpn/ca.crt
      cert /etc/openvpn/server.crt
      key  /etc/openvpn/server.key

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
