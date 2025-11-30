{
  pkgs,
  secrets,
  ...
}: {
  services.caddy.virtualHosts."ldap.home.emilbroman.me".extraConfig = ''
    forward_auth 127.0.0.1:9091 {
      uri /api/authz/forward-auth
      copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
    }
    reverse_proxy http://127.0.0.1:17170
  '';

  environment.etc."lldap/service-account-password".text = secrets.ldap.serviceAccount.password;

  services.lldap = {
    enable = true;
    package = pkgs.lldap;

    settings = let
      baseDn = "dc=home,dc=emilbroman,dc=me";
    in {
      ldap_host = "127.0.0.1";
      ldap_port = 3890;

      http_host = "127.0.0.1";
      http_port = 17170;

      ldap_base_dn = baseDn;

      ldap_user_dn = "service";
      ldap_user_email = secrets.ldap.serviceAccount.email;
      ldap_user_pass_file = "/etc/lldap/service-account-password";
      force_ldap_user_pass_reset = "always";

      smtp_options = {
        enable_password_reset = true;
        server = secrets.smtp.hostname;
        port = 587;
        user = secrets.smtp.username;
        password = secrets.smtp.password;
        from = "home@emilbroman.me";
      };
    };
  };
}
