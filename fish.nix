let

palette = import ./palette.nix;

variables = {
  fish_term24bit = "1";
  fish_color_autosuggestion = palette.gray."250";
  fish_color_cancel = "-r";
  fish_color_command = "${palette.yellow."350"} --bold";
  fish_color_comment = "${palette.gray."250"} --italics";
  fish_color_cwd = palette.orange."250";
  fish_color_cwd_root = palette.orange."350";
  fish_color_end = palette.gray."250";
  fish_color_error = palette.red."350";
  fish_color_escape = palette.orange."250";
  fish_color_history_current = "normal";
  fish_color_host = "normal";
  fish_color_host_remote = "normal";
  fish_color_match = palette.gray."300";
  fish_color_normal = palette.gray."150";
  fish_color_operator = palette.magenta."200";
  fish_color_param = palette.yellow."200";
  fish_color_quote = palette.green."200";
  fish_color_redirection = "${palette.magenta."100"} --italics";
  fish_color_search_match = "--background=${palette.gray."300"}";
  fish_color_selection = "--background=${palette.gray."300"}";
  fish_color_status = "${palette.yellow."350"} --underline";
  fish_color_user = palette.orange."350";
  fish_color_valid_path = "${palette.yellow."200"} --underline";
};

in

{
  systemConfig = {
    shellInit = ''
      fish_add_path /opt/homebrew/bin
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

        set_color ${palette.orange."300"} --background ${palette.orange."150"}
        printf ' '(hostname | awk -F\. '{print $1}')' '

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
