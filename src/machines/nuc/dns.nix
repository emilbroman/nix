{
  services.dnsmasq = {
    enable = true;

    settings.local = "/bb3.site/";

    settings.address = [
      "/srv.bb3.site/10.0.0.4"
      "/mini.bb3.site/10.0.0.5"
      "/macbook.bb3.site/10.0.0.6"
      "/nuc.bb3.site/10.0.0.2"
      "/.bb3.site/10.0.0.2"
    ];

    settings.server = [
      "1.1.1.1"
      "8.8.8.8"
    ];
  };
}
