{
  outputs = {self}: {
    system-module = {
      system.defaults.NSGlobalDomain = {
        InitialKeyRepeat = 9;
        KeyRepeat = 2;

        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticInlinePredictionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
      };

      system.defaults.NSGlobalDomain."com.apple.mouse.tapBehavior" = let
        tapToClick = 1;
      in
        tapToClick;

      system.defaults.universalaccess.closeViewScrollWheelToggle = true;

      system.defaults.CustomUserPreferences."com.apple.WindowManager" = {
        EnableTiledWindowMargins = 0;
      };

      system.defaults.dock = {
        persistent-apps = [];
        autohide = true;
      };

      power.sleep = {
        computer = "never";
        harddisk = "never";
        display = 20;
      };

      system.keyboard.enableKeyMapping = true;
      system.keyboard.remapCapsLockToEscape = true;
    };
  };
}
