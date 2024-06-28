let

palette = import ./palette.nix;

variables = {
  fish_color_autosuggestion = "77849E";
  fish_color_cancel = "\x2dr";
  fish_color_command = "ECD444\x1e\x2d\x2dbold";
  fish_color_comment = "77849E\x1e\x2d\x2ditalics";
  fish_color_cwd = "FB997D";
  fish_color_cwd_root = "F46036";
  fish_color_end = "77849E";
  fish_color_error = "E4455A";
  fish_color_escape = "FB997D";
  fish_color_history_current = "normal";
  fish_color_host = "normal";
  fish_color_host_remote = "normal";
  fish_color_match = "354256";
  fish_color_normal = "E6EAF1";
  fish_color_operator = "FD6BDD";
  fish_color_param = "F8EB9E";
  fish_color_quote = "6AEAA0";
  fish_color_redirection = "FFD2F5\x1e\x2d\x2ditalics";
  fish_color_search_match = "\x2d\x2dbackground\x3d354256";
  fish_color_selection = "\x2d\x2dbackground\x3d354256";
  fish_color_status = "ECD444\x1e\x2d\x2dunderline";
  fish_color_user = "F46036";
  fish_color_valid_path = "F8EB9E\x1e\x2d\x2dunderline";
};

in

{
  systemConfig = {
    shellInit = ''
      fish_add_path /run/current-system/sw/bin /opt/homebrew/bin
    '';
  };

  userConfig = {
    interactiveShellInit = ''
      # Disable greeting
      set fish_greeting

      # Enter GPG password using this TTY
      export GPG_TTY=(tty)
    '' + builtins.concatStringsSep "\n" (
      map
        (key: ''
          set ${key} ${variables.${key}}
        '')
        (builtins.attrNames variables)
    );
    shellAliases = {
      co = "git checkout";
      gap = "git add -p .";
    };
    functions = {
      dotenv = {
        argumentNames = ["file"];
        body = ''
          if test -z $file
            set file ".env"
          end

          if not test -e $file
            set_color red --bold
            echo -n $file
            set_color normal
            set_color ${palette.gray."250"} --italic
            echo " does not exist"
            return 1
          end

          begin
            set -l IFS
            set code (awk '
              /^[[:space:]]*(#|$)/ {
                next
              }
              {
                sub("=", "__SPACE__")
              }
              /^[[:space:]]*[^ ]+[[:space:]]+"/ {
                print "set -gx " $0
                next
              }
              {
                sub("__SPACE__", " \\"")
                print "set -gx " $0 "\\""
              }
            ' $file)
          end

          eval $code

          set_color yellow
          echo -n "$file "
          set_color ${palette.gray."250"}
          echo "↩"
        '';
      };

      fish_prompt = ''
        set -l last_command_status $status

        if test $last_command_status -ne 0
            set_color ${palette.red."100"} --background ${palette.red."350"}
            printf ' %d ' $last_command_status
        end

        set_color ${palette.gray."200"} --background ${palette.gray."300"}
        printf ' '(fish_prompt_pwd_dir_length=0 prompt_pwd)' '

        set_color normal
        printf ' '
      '';

      fish_user_key_bindings = ''
        bind \cx\ce 'edit_command_buffer'
      '';

      mkcd = ''
        mkdir -p $argv
        cd $argv[(count $argv)]
      '';

      nd = ''
        set stat $status

        if test $stat -eq 0
          set icon "✅"
          set sound "Alert"
        else
          set icon "❌"
          set sound "Funk"
        end

        set message 'Task completed with '$stat
        set title $icon' Ding!'

        osascript \
          -e 'display notification "'$message'" with title "'$title'" sound name "'$sound'"'

        return $stat
      '';
    };
  };
}
