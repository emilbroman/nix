{self}: {
  muted = self.palette.gray."250";

  prompt = {
    errorStatus = {
      background = self.palette.red."350";
      foreground = self.palette.red."100";
    };
    shellDepth = {
      background = self.palette.blue."100";
      foreground = self.palette.blue."350";
    };
  };

  variables = {
    fish_color_autosuggestion = self.palette.gray."250";
    fish_color_cancel = "-r";
    fish_color_command = "${self.palette.yellow."350"} --bold";
    fish_color_comment = "${self.palette.gray."250"} --italics";
    fish_color_cwd = self.palette.orange."250";
    fish_color_cwd_root = self.palette.orange."350";
    fish_color_end = self.palette.gray."250";
    fish_color_error = self.palette.red."350";
    fish_color_escape = self.palette.orange."250";
    fish_color_history_current = "normal";
    fish_color_host = "normal";
    fish_color_host_remote = "normal";
    fish_color_match = self.palette.gray."300";
    fish_color_normal = self.palette.gray."150";
    fish_color_operator = self.palette.magenta."200";
    fish_color_param = self.palette.yellow."200";
    fish_color_quote = self.palette.green."200";
    fish_color_redirection = "${self.palette.magenta."100"} --italics";
    fish_color_search_match = "--background=${self.palette.gray."300"}";
    fish_color_selection = "--background=${self.palette.gray."300"}";
    fish_color_status = "${self.palette.yellow."350"} --underline";
    fish_color_user = self.palette.orange."350";
    fish_color_valid_path = "${self.palette.yellow."200"} --underline";
  };
}
