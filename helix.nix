{
  settings = {
    theme = "gruvbox_dark_soft";

    editor.cursor-shape = {
      insert = "bar";
      normal = "block";
      select = "underline";
    };
    
    editor.file-picker = {
      hidden = false;
    };

    editor.true-color = true;
  };

  languages.language = [
    {
      name = "markdown";
      auto-format = true;
      formatter.command = "yarn";
      formatter.args = ["prettier" "--parser" "markdown"];
    }
  ];
}
