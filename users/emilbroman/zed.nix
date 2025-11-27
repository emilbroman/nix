let
  font = import ./font.nix;
in {
  home.file.".config/zed/settings.json".text = builtins.toJSON {
    buffer_font_family = font.mono.name;
    buffer_font_size = font.mono.size;
    buffer_line_height = {
      custom = font.mono.leading;
    };
    ui_font_family = font.sans.name;
    ui_font_size = font.sans.size;
    ui_line_height = {
      custom = font.sans.leading;
    };
    helix_mode = true;
    theme = {
      mode = "system";
      light = "One Light";
      dark = "One Dark";
    };

    show_completions_on_input = false;

    languages.YAML.language_servers = [
      "yaml-language-server"
      "package-version-server"
    ];

    lsp.yaml-language-server.settings = {
      yaml.schemas = {
        "https://backoffice.a2d-dev.tv/schemas/1.0/manifest.json" = "/backoffice.yaml";
      };
    };

    tab_bar = {
      show = false;
    };
  };
}
