{self}: {
  fg = self.palette.gray."350";
  bg = self.backdrop;
  black = self.palette.gray."350";
  red = self.palette.red."400";
  green = self.palette.green."400";
  yellow = self.palette.yellow."400";
  blue = self.palette.blue."400";
  magenta = self.palette.magenta."400";
  cyan = self.palette.cyan."400";
  white = self.palette.gray."150";
  orange = self.palette.orange."400";

  clock = {
    foreground = self.palette.gray."250";
  };

  frame = {
    selected = self.palette.gray."300";
    unselected = self.palette.gray."200";
    highlight = self.palette.gray."350";
  };

  pill = {
    inactive = {
      background = self.palette.gray."150";
      foreground = self.palette.gray."300";
      tag.background = self.palette.gray."100";
      tag.foreground = self.palette.gray."250";
    };
    active = {
      background = self.palette.gray."250";
      foreground = self.palette.gray."100";
      tag.background = self.palette.gray."200";
      tag.foreground = self.palette.gray."150";
    };
  };
}
