{
  outputs = {self}: {
    palette = import ./palette.nix;
    backdrop = self.palette.gray."100";
    hexpalette = builtins.mapAttrs (_: color: builtins.mapAttrs (_: hex: "#${hex}") color) self.palette;

    font = let
      ppGrotesk = {
        mono.name = "PP Right Grotesk Mono";
        mono.size = 13;
        mono.leading = 1.15;

        sans.name = "PP Right Grotesk Text";
        sans.size = 15;
        sans.leading = 1.4;
      };
      _berkeleyMono = {
        name = "Berkeley Mono";
        size = 12;
        leading = 1.1;
      };
      _cabinetGrotesk = {
        name = "Cabinet Grotesk";
        size = 15;
        leading = 1.4;
      };
    in {
      mono = ppGrotesk.mono;
      sans = ppGrotesk.sans;
      cellWidth = 1.0;
    };

    wezterm = import ./wezterm.nix {inherit self;};
    fish = import ./fish.nix {inherit self;};
    helix = import ./helix.nix {inherit self;};
    zellij = import ./zellij.nix {inherit self;};
  };
}
