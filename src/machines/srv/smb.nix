{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    bindfs
  ];

  systemd.services.fakemount = {
    description = "Fake Mount";
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      ExecStart = "${pkgs.bash}/bin/bash -c 'mkdir -p /var/lib/smbfakedrive /mnt/smb && ${pkgs.bindfs}/bin/bindfs /var/lib/smbfakedrive /mnt/smb && sleep infinity'";
      Restart = "always";
    };
  };

  services.samba = {
    enable = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "BB3 Drive";
        "security" = "user";
        "hosts allow" = "127.0.0.1 10.0.0.0/8 localhost";
        "hosts deny" = "0.0.0.0/0";
      };
      "pvc" = {
        "path" = "/mnt/smb/pvc";
        "browseable" = "yes";
        "read only" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "guest ok" = "no";
      };
    };
  };
}
