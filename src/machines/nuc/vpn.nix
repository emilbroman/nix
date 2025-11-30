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

      ca   /var/lib/openvpn/pki/ca.crt
      cert /var/lib/openvpn/pki/server.crt
      key  /var/lib/openvpn/pki/server.key
      dh   /var/lib/openvpn/pki/dh.pem

      server 10.8.0.0 255.255.255.0
      keepalive 10 120
      persist-key
      persist-tun
      topology subnet

      push "route 10.0.0.0 255.255.255.0"
      push "dhcp-option DNS 10.0.0.2"

      plugin ${pkgs.openvpn-auth-ldap}/lib/openvpn/openvpn-auth-ldap.so "/etc/openvpn/auth-ldap.conf"

      verify-client-cert none
      username-as-common-name

      tls-version-min 1.2
      cipher AES-256-GCM
      data-ciphers AES-256-GCM:AES-128-GCM:CHACHA20-POLY1305
      data-ciphers-fallback AES-256-GCM

      verb 3
    '';
  };

  environment.etc."openvpn/auth-ldap.conf".text = ''
    <LDAP>
      URL ldap://127.0.0.1:3890
      BindDN "uid=service,ou=people,dc=home,dc=emilbroman,dc=me"
      Password "${secrets.ldap.serviceAccount.password}"
      Timeout 15
      TLSEnable no
      FollowReferrals yes
    </LDAP>

    <Authorization>
      BaseDN "ou=people,dc=home,dc=emilbroman,dc=me"
      SearchFilter "(uid=%u)"
      RequireGroup false
    </Authorization>
  '';
}
