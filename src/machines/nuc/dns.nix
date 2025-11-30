{
  services.dnsmasq = {
    enable = true;

    settings.local = "/home.emilbroman.me/";

    settings.address = [
      "/.home.emilbroman.me/10.0.0.2"
    ];

    settings.server = [
      "1.1.1.1"
      "8.8.8.8"
    ];
  };
}
