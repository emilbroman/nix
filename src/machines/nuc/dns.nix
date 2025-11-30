{
  services.dnsmasq = {
    enable = true;

    settings.local = "/home.emilbroman.me/";

    settings.address = [
    ];

    settings.server = [
      "1.1.1.1"
      "8.8.8.8"
    ];
  };
}
