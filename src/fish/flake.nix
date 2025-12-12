{
  outputs = {
    self,
    nixpkgs,
  }: {
    system-module = {
      programs.fish = {
        enable = true;
      };
    };

    home-module = {theme}: {
      lib,
      config,
      ...
    }: {
      options.showHostnameInFishPrompt = lib.mkEnableOption "hostname in fish prompt";

      config = {
        programs.fish = {
          enable = true;

          shellInit = ''
            fish_add_path /opt/homebrew/bin
            fish_add_path $HOME/.nix-profile/bin
          '';
          interactiveShellInit = let
            variables =
              theme.fish.variables
              // {
                fish_term24bit = "1";
              };
          in
            ''
              # Disable greeting
              set fish_greeting

              # Enter GPG password using this TTY
              export GPG_TTY=(tty)

              export COLORTERM=truecolor
            ''
            + builtins.concatStringsSep "\n" (
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
            nix-apply = ''
              cd ~/code/nix
              git add .
              nix-rebuild
              and git commit
              and git push
            '';
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
                  set_color ${theme.fish.muted} --italic
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
                    /^[[:space:]]*[^ ]+[[:space:]]*"/ {
                      sub("__SPACE__", " ")
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
                set_color ${theme.fish.muted}
                echo "↩"
              '';
            };

            fish_prompt = ''
              set -l last_command_status $status

              if test $last_command_status -ne 0
                set_color ${theme.fish.prompt.errorStatus.foreground} --background ${theme.fish.prompt.errorStatus.background}
                printf ' %d ' $last_command_status
              end

              set -l nix_shell_depth (pstree -p %self | rg '\bfish' -c | xargs expr -1 +)
              if test $nix_shell_depth -gt 0
                set_color ${theme.fish.prompt.shellDepth.foreground} --background ${theme.fish.prompt.shellDepth.background}
                printf ' '
                for i in (seq $nix_shell_depth)
                  printf '+'
                end
                printf ' '
              end

              ${
                if config.showHostnameInFishPrompt
                then ''
                  set_color ${theme.fish.prompt.hostname.foreground} --background ${theme.fish.prompt.hostname.background}
                  printf ' '(hostname)' '
                ''
                else ""
              }

              set_color ${theme.zellij.pill.inactive.foreground} --background ${theme.zellij.pill.inactive.background}
              printf ' '(prompt_pwd --full-length-dirs 4 --dir-length 3)' '

              if git status &>/dev/null
                set_color f14e32 --background fadfdb
                printf ' '(string shorten --left --max 30 (git branch --show-current))' '

                set_color normal
                echo

                set_color ${theme.fish.muted}
                printf ' ⊢ '
              else
                set_color normal
                printf ' '
              end
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
      };
    };
  };
}
