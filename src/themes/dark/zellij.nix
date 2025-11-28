{self}: {
  fg = self.palette.gray."250";
  bg = self.backdrop;
  black = self.palette.gray."400";
  red = self.palette.red."400";
  green = self.palette.green."350";
  yellow = self.palette.yellow."350";
  blue = self.palette.blue."350";
  magenta = self.palette.magenta."350";
  cyan = self.palette.cyan."350";
  white = self.palette.gray."250";
  orange = self.palette.orange."350";

  clock = {
    foreground = self.palette.gray."250";
  };

  pill = {
    inactive = {
      background = self.palette.gray."300";
      foreground = self.palette.gray."200";
    };
    active = {
      background = self.palette.gray."200";
      foreground = self.palette.gray."300";
    };
  };
}
