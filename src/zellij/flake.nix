{
  inputs = {
    zjstatus.url = "https://github.com/dj95/zjstatus/releases/download/v0.21.0/zjstatus.wasm";
    zjstatus.flake = false;
  };

  outputs = {
    self,
    zjstatus,
  }: {
    home-module = {theme}: {pkgs, ...}: {
      home.packages = with pkgs; [
        zellij
      ];

      home.file.".config/zellij/config.kdl".text = ''
        keybinds clear-defaults=true {
            shared_except "normal" {
                bind "Esc" { SwitchToMode "Normal"; }
            }

            normal {
                bind "Alt h" { MoveFocus "Left"; }
                bind "Alt l" { MoveFocus "Right"; }
                bind "Alt j" { MoveFocus "Down"; }
                bind "Alt k" { MoveFocus "Up"; }

                bind "Alt f" { ToggleFloatingPanes; }
                bind "Alt z" { ToggleFocusFullscreen; }

                bind "Alt H" { NewPane "Left"; }
                bind "Alt L" { NewPane "Right"; }
                bind "Alt J" { NewPane "Down"; }
                bind "Alt K" { NewPane "Up"; }

                bind "Alt t" { NewTab; }
                bind "Alt n" { GoToNextTab; }
                bind "Alt p" { GoToPreviousTab; }
                bind "Alt q" { CloseTab; }
                bind "Alt c" { NewPane; }
            }

            shared_except "resize" {
                bind "Alt r" { SwitchToMode "Resize"; }
            }

            resize {
                bind "Alt r" { SwitchToMode "Normal"; }

                bind "h" { Resize "Increase Left"; }
                bind "j" { Resize "Increase Down"; }
                bind "k" { Resize "Increase Up"; }
                bind "l" { Resize "Increase Right"; }

                bind "H" { Resize "Decrease Left"; }
                bind "J" { Resize "Decrease Down"; }
                bind "K" { Resize "Decrease Up"; }
                bind "L" { Resize "Decrease Right"; }

                bind "=" "+" { Resize "Increase"; }
                bind "-" { Resize "Decrease"; }
            }

            shared_except "move" {
                bind "Alt m" { SwitchToMode "Move"; }
            }

            move {
                bind "Alt m" { SwitchToMode "Normal"; }

                bind "h" { MovePane "Left"; }
                bind "j" { MovePane "Down"; }
                bind "k" { MovePane "Up"; }
                bind "l" { MovePane "Right"; }
            }

            shared_except "renametab" {
                bind "Alt N" { SwitchToMode "RenameTab"; TabNameInput 0; }
            }

            renametab {
                bind "Alt N" { SwitchToMode "Normal"; }
                bind "Esc" { UndoRenameTab; SwitchToMode "Normal"; }
            }

            shared_except "entersearch" "search" {
                bind "Alt S" { SwitchToMode "EnterSearch"; }
            }

            entersearch {
                bind "Alt S" { SwitchToMode "Normal"; }
                bind "Ctrl c" "Esc" { SwitchToMode "Scroll"; }
                bind "Enter" { SwitchToMode "Search"; }
            }

            search {
                bind "Alt S" { SwitchToMode "Normal"; }
                bind "Ctrl c" { ScrollToBottom; SwitchToMode "Normal"; }
                bind "j" "Down" { ScrollDown; }
                bind "k" "Up" { ScrollUp; }
                bind "Ctrl f" "PageDown" "Right" "l" { PageScrollDown; }
                bind "Ctrl b" "PageUp" "Left" "h" { PageScrollUp; }
                bind "d" { HalfPageScrollDown; }
                bind "u" { HalfPageScrollUp; }
                bind "n" { Search "down"; }
                bind "p" { Search "up"; }
                bind "c" { SearchToggleOption "CaseSensitivity"; }
                bind "w" { SearchToggleOption "Wrap"; }
                bind "o" { SearchToggleOption "WholeWord"; }
            }
        }

        plugins {
            tab-bar location="zellij:tab-bar"
            status-bar location="zellij:status-bar"
            strider location="zellij:strider"
            compact-bar location="zellij:compact-bar"
            session-manager location="zellij:session-manager"
            welcome-screen location="zellij:session-manager" {
                welcome_screen true
            }
            filepicker location="zellij:strider" {
                cwd "/"
            }
        }

        // Choose what to do when zellij receives SIGTERM, SIGINT, SIGQUIT or SIGHUP
        // eg. when terminal window with an active zellij session is closed
        // Options:
        //   - detach (Default)
        //   - quit
        //
        // on_force_close "quit"

        //  Send a request for a simplified ui (without arrow fonts) to plugins
        //  Options:
        //    - true
        //    - false (Default)
        //
        simplified_ui true

        // Choose the path to the default shell that zellij will use for opening new panes
        // Default: $SHELL
        //
        // default_shell "fish"

        // Choose the path to override cwd that zellij will use for opening new panes
        //
        default_cwd "~/code"

        // Toggle between having pane frames around the panes
        // Options:
        //   - true (default)
        //   - false
        //
        pane_frames false

        // Toggle between having Zellij lay out panes according to a predefined set of layouts whenever possible
        // Options:
        //   - true (default)
        //   - false
        //
        // auto_layout true

        // Whether sessions should be serialized to the cache folder (including their tabs/panes, cwds and running commands) so that they can later be resurrected
        // Options:
        //   - true (default)
        //   - false
        //
        // session_serialization false

        // Whether pane viewports are serialized along with the session, default is false
        // Options:
        //   - true
        //   - false (default)
        // serialize_pane_viewport true

        // Scrollback lines to serialize along with the pane viewport when serializing sessions, 0
        // defaults to the scrollback size. If this number is higher than the scrollback size, it will
        // also default to the scrollback size. This does nothing if `serialize_pane_viewport` is not true.
        //
        scrollback_lines_to_serialize 100000

        // Define color themes for Zellij
        // For more examples, see: https://github.com/zellij-org/zellij/tree/main/example/themes
        // Once these themes are defined, one of them should to be selected in the "theme" section of this file
        //
        themes {
            emil {
                fg "#${theme.zellij.fg}"
                bg "#${theme.zellij.bg}"
                black "#${theme.zellij.black}"
                red "#${theme.zellij.red}"
                green "#${theme.zellij.green}"
                yellow "#${theme.zellij.yellow}"
                blue "#${theme.zellij.blue}"
                magenta "#${theme.zellij.magenta}"
                cyan "#${theme.zellij.cyan}"
                white "#${theme.zellij.white}"
                orange "#${theme.zellij.orange}"
            }
        }

        // Choose the theme that is specified in the themes section.
        // Default: default
        //
        theme "emil"

        // The name of the default layout to load on startup
        // Default: "default"
        //
        // default_layout "compact"

        // Disable startup tips
        show_startup_tips false

        // Choose the mode that zellij uses when starting up.
        // Default: normal
        //
        // default_mode "locked"

        // Toggle enabling the mouse mode.
        // On certain configurations, or terminals this could
        // potentially interfere with copying text.
        // Options:
        //   - true (default)
        //   - false
        //
        // mouse_mode false

        // Configure the scroll back buffer size
        // This is the number of lines zellij stores for each pane in the scroll back
        // buffer. Excess number of lines are discarded in a FIFO fashion.
        // Valid values: positive integers
        // Default value: 10000
        //
        // scroll_buffer_size 10000

        // Provide a command to execute when copying text. The text will be piped to
        // the stdin of the program to perform the copy. This can be used with
        // terminal emulators which do not support the OSC 52 ANSI control sequence
        // that will be used by default if this option is not set.
        // Examples:
        //
        // copy_command "xclip -selection clipboard" // x11
        // copy_command "wl-copy"                    // wayland
        // copy_command "pbcopy"                     // osx

        // Choose the destination for copied text
        // Allows using the primary selection buffer (on x11/wayland) instead of the system clipboard.
        // Does not apply when using copy_command.
        // Options:
        //   - system (default)
        //   - primary
        //
        // copy_clipboard "primary"

        // Enable or disable automatic copy (and clear) of selection when releasing mouse
        // Default: true
        //
        // copy_on_select false

        // Path to the default editor to use to edit pane scrollbuffer
        // Default: $EDITOR or $VISUAL
        //
        // scrollback_editor "/usr/bin/vim"

        // When attaching to an existing session with other users,
        // should the session be mirrored (true)
        // or should each user have their own cursor (false)
        // Default: false
        //
        // mirror_session true

        // The folder in which Zellij will look for layouts
        //
        // layout_dir "/path/to/my/layout_dir"

        // The folder in which Zellij will look for themes
        //
        // theme_dir "/path/to/my/theme_dir"

        // Enable or disable the rendering of styled and colored underlines (undercurl).
        // May need to be disabled for certain unsupported terminals
        // Default: true
        //
        // styled_underlines false

        // Enable or disable writing of session metadata to disk (if disabled, other sessions might not know
        // metadata info on this session)
        // Default: false
        //
        // disable_session_metadata true
      '';

      home.file.".config/zellij/layouts/default.kdl".text = ''
        layout {
          default_tab_template {
            pane size=1 borderless=true {
              plugin location="file:${zjstatus}" {
                format_left   "{tabs}"
                format_right  "{command_gcloud} {command_kubectx} {mode} {datetime} "

                border_enabled  "false"

                // hide_frame_for_single_pane "true"

                mode_normal   "#[fg=#${theme.zellij.pill.inactive.foreground},bg=#${theme.zellij.pill.inactive.background}] {name} "
                mode_default_to_mode "normal"

                tab_normal   "#[bg=#${theme.zellij.pill.inactive.background},fg=#${theme.zellij.pill.inactive.foreground}] {name} #[normal] "
                tab_active   "#[bg=#${theme.zellij.pill.active.background},fg=#${theme.zellij.pill.active.foreground}] {name} #[normal] "

                datetime          "#[fg=#${theme.zellij.clock.foreground}] {format}"
                datetime_format   "%H:%M"
                datetime_timezone "Europe/Stockholm"

                command_kubectx_command     "sh -c \"~/.nix-profile/bin/rg '^current-context: (.*)$' ~/.kube/config -r '$1'\""
                command_kubectx_format      "#[bg=#326ce5,fg=#ffffff] k8s #[fg=#326ce5,bg=#ffffff] {stdout}{stderr} "
                command_kubectx_interval    "5"
                command_kubectx_rendermode  "static"
                command_kubectx_cwd         "/"
                command_kubectx_env         {}

                command_gcloud_command     "./fish -c \"~/.nix-profile/bin/rg '^project = (.*)$' -r '$1' ~/.config/gcloud/configurations/config_(cat ~/.config/gcloud/active_config)\""
                command_gcloud_format      "#[bg=#4285f4,fg=#ffffff] gcp #[fg=#4285f4,bg=#ffffff] {stdout}{stderr} "
                command_gcloud_interval    "5"
                command_gcloud_rendermode  "static"
                command_gcloud_cwd         "/run/current-system/sw/bin"
                command_gcloud_env         {}
              }
            }

            children
          }
        }
      '';
    };
  };
}
