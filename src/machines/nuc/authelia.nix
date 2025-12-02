{secrets, ...}: {
  services.caddy.virtualHosts."id.home.emilbroman.me".extraConfig = ''
    reverse_proxy http://127.0.0.1:9091
  '';

  services.authelia.instances.main = {
    enable = true;

    secrets = {
      storageEncryptionKeyFile = "/var/lib/authelia-main/storage-encryption-secret";
      jwtSecretFile = "/var/lib/authelia-main/jwt-secret";
      sessionSecretFile = "/var/lib/authelia-main/session-secret";
    };

    settings = {
      server.address = "tcp://127.0.0.1:9091";

      default_2fa_method = "webauthn";
      totp.disable = true;

      theme = "light";

      storage = {
        local = {
          path = "/var/lib/authelia-main/authelia.sqlite3";
        };
      };

      session = {
        cookies = [
          {
            name = "authelia_session";
            same_site = "lax";
            expiration = "1h";
            inactivity = "5m";
            domain = "home.emilbroman.me";
            default_redirection_url = "https://id.home.emilbroman.me/";
            authelia_url = "https://id.home.emilbroman.me";
          }
        ];
      };

      notifier = {
        smtp = {
          address = "smtp://${secrets.smtp.hostname}:587";
          username = secrets.smtp.username;
          password = secrets.smtp.password;
          sender = "no-reply@emilbroman.me";
          subject = "Authelia notification";
          startup_check_address = "authelia@emilbroman.me";
        };
      };

      authentication_backend = {
        ldap = {
          implementation = "custom";
          address = "ldap://127.0.0.1:3890";
          base_dn = "dc=home,dc=emilbroman,dc=me";

          user = "uid=service,ou=people,dc=home,dc=emilbroman,dc=me";
          password = secrets.ldap.serviceAccount.password;

          users_filter = "(&(|({username_attribute}={input})({mail_attribute}={input}))(objectClass=person))";
          groups_filter = "(&(objectClass=groupOfNames)(member={dn}))";

          attributes = {
            username = "uid";
            display_name = "cn";
            mail = "mail";
            group_name = "cn";
          };
        };
      };

      access_control = {
        default_policy = "two_factor";
      };
    };
  };
}
