{
  outputs = {self}: {
    palette = import ./palette.nix;
    backdrop = self.palette.gray."350";
    hexpalette = builtins.mapAttrs (_: color: builtins.mapAttrs (_: hex: "#${hex}") color) self.palette;

    font = {
      mono.name = "PP Right Grotesk Mono";
      mono.size = 13;
      mono.leading = 1.15;

      sans.name = "PP Right Grotesk Text";
      sans.size = 15;
      sans.leading = 1.4;

      cellWidth = 1.0;
    };

    wezterm = import ./wezterm.nix {inherit self;};
    fish = import ./fish.nix {inherit self;};
    helix = import ./helix.nix {inherit self;};
    zellij = import ./zellij.nix {inherit self;};
  };
}
