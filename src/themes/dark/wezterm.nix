{self}: {
  background = self.backdrop;
  foreground = self.palette.gray."150";
  cursorForeground = self.palette.gray."350";
  cursorBackground = self.palette.gray."150";
  ansi = {
    black = self.palette.gray."300";
    red = self.palette.red."300";
    green = self.palette.green."250";
    yellow = self.palette.yellow."250";
    blue = self.palette.blue."250";
    magenta = self.palette.magenta."250";
    cyan = self.palette.cyan."250";
    white = self.palette.gray."150";
  };
  brights = {
    black = self.palette.gray."250";
    red = self.palette.red."150";
    green = self.palette.green."150";
    yellow = self.palette.yellow."150";
    blue = self.palette.blue."150";
    magenta = self.palette.magenta."150";
    cyan = self.palette.cyan."150";
    white = self.palette.gray."100";
  };
}
