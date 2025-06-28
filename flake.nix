{
  description = "Emil's Nix Flake for macOS & Linux";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    home-manager.url = "github:nix-community/home-manager";

    zjstatus.url = "https://github.com/dj95/zjstatus/releases/latest/download/zjstatus.wasm";
    zjstatus.flake = false;
  };

  outputs = {
    self,
    nixpkgs,
    nix-homebrew,
    nix-darwin,
    home-manager,
    zjstatus,
  }: let
    specialArgs = {
      inherit zjstatus;
      flake = self;
    };
  in {
    darwinConfigurations."emils-macbook" = nix-darwin.lib.darwinSystem {
      inherit specialArgs;
      modules = [
        {
          nixpkgs.hostPlatform = "aarch64-darwin";
          networking.hostName = "emils-macbook";
          ids.gids.nixbld = 350;
        }
        home-manager.darwinModules.home-manager
        nix-homebrew.darwinModules.nix-homebrew
        ./darwin.nix
      ];
    };

    darwinConfigurations."emils-mini" = nix-darwin.lib.darwinSystem {
      inherit specialArgs;
      modules = [
        {
          nixpkgs.hostPlatform = "aarch64-darwin";
          networking.hostName = "emils-mini";
        }
        home-manager.darwinModules.home-manager
        nix-homebrew.darwinModules.nix-homebrew
        ./darwin.nix
      ];
    };

    nixosConfigurations."nuc" = nixpkgs.lib.nixosSystem {
      inherit specialArgs;
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        ./users/nixos.nix
        ./kubernetes/master.nix
        /etc/nixos/hardware-configuration.nix
        home-manager.nixosModules.home-manager
        {
          networking.hostName = "nuc";
          system.stateVersion = "24.11";

          # Use the systemd-boot EFI boot loader.
          boot.loader.systemd-boot.enable = true;
          boot.loader.efi.canTouchEfiVariables = true;

          networking.wireless.enable = true;

          time.timeZone = "Europe/Stockholm";

          virtualisation.docker.enable = true;

          # Select internationalisation properties.
          i18n.defaultLocale = "en_US.UTF-8";
          console = {
            font = "Lat2-Terminus16";
            keyMap = "us";
          };

          # Enable the OpenSSH daemon.
          services.openssh.enable = true;

          # Disable firewall (use firewall in router).
          networking.firewall.enable = false;

          home-manager.sharedModules = [
            {
              programs.fish.shellAliases.nix-rebuild = "sudo nixos-rebuild switch --flake ~/code/nix --impure";
            }
          ];

          services.caddy.enable = true;

          services.caddy.virtualHosts."home.emilbroman.me".extraConfig = ''
            reverse_proxy http://10.0.0.4:30080
          '';

          services.caddy.virtualHosts."ollama.home.emilbroman.me".extraConfig = ''
            basic_auth {
              emil $2y$10$eViJe8Yioo.Qb.oPSohXm.A.kB0GI3pBEahtGkPM/d0DwLD.crApK
            }

            reverse_proxy http://10.0.0.4:11434
          '';

          services.caddy.virtualHosts."kvm.home.emilbroman.me".extraConfig = ''
            reverse_proxy https://10.0.0.3 {
              transport http {
                tls_insecure_skip_verify
              }
            }
          '';

          services.caddy.virtualHosts."omada.home.emilbroman.me".extraConfig = ''
            reverse_proxy https://localhost:8043 {
              transport http {
                tls_insecure_skip_verify
              }
            }
          '';
        }
      ];
    };

    nixosConfigurations."srv" = nixpkgs.lib.nixosSystem {
      inherit specialArgs;
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        system = "x86_64-linux";

        config.allowUnfree = true;
        config.cudaSupport = true;
        config.cudaCapability = "8.9";

        overlays = [
          # (final: prev: {
          #   gamescope = prev.gamescope.overrideAttrs (old: {
          #     src = final.fetchgit {
          #       url = "https://github.com/ValveSoftware/gamescope.git";
          #       rev = "81e40911e425c41071f3f684eba76b154b25f7af"; # latest as of now
          #       sha256 = "sha256-C2MMutgPoMWZJwO/Sq4FoZxble3/W08kLHQs9WdTgYg=";
          #       fetchSubmodules = true;
          #     };
          #     version = "master";
          #     mesonFlags =
          #       old.mesonFlags or []
          #       ++ [
          #         "-Denable_openvr_support=false"
          #       ];

          #     nativeBuildInputs =
          #       old.nativeBuildInputs
          #       ++ [
          #         final.pkg-config
          #         final.meson
          #         final.ninja
          #       ];
          #   });
          # })
        ];
      };
      modules = [
        ./configuration.nix
        ./users/nixos.nix
        ./kubernetes/node.nix
        /etc/nixos/hardware-configuration.nix
        home-manager.nixosModules.home-manager
        ({
          config,
          pkgs,
          ...
        }: {
          system.stateVersion = "24.11";
          networking.hostName = "srv";
          networking.networkmanager.enable = true;

          # Use the systemd-boot EFI boot loader.
          boot.loader.systemd-boot.enable = true;
          boot.loader.systemd-boot.configurationLimit = 1;
          boot.loader.efi.canTouchEfiVariables = true;
          boot.loader.timeout = 1;

          time.timeZone = "Europe/Stockholm";

          virtualisation.docker.enable = true;

          # Select internationalisation properties.
          i18n.defaultLocale = "en_US.UTF-8";
          console = {
            font = "Lat2-Terminus16";
            keyMap = "us";
          };

          services.displayManager = {
            autoLogin = {
              enable = true;
              user = "emilbroman";
            };

            # sddm = {
            #   enable = true;
            #   wayland = {
            #     enable = true;
            #   };
            # };
            gdm = {
              enable = false;
              wayland = false;
            };
          };
          # services.displayManager.gdm.enable = false;

          # services.desktopManager.plasma6.enable = true;
          # services.desktopManager.gnome.enable = false;

          # security.pam.services.gdm-password.enableGnomeKeyring = true;

          # displayManager.startx.enable = true;
          # displayManager.xpra.enable = true;
          # desktopManager.budgie.enable = true;

          home-manager.users.emilbroman = {
            home.file.".config/openbox/autostart".text = ''
              exec ${pkgs.steam}/bin/steam -steamos -tenfoot
            '';
          };

          environment.sessionVariables = {
            # __GL_MaxFramesAllowed = "1";
            # __GL_YIELD = "USLEEP";
          };

          # services.seatd.enable = true;
          services.xserver = {
            enable = true;

            displayManager.lightdm.enable = true;
            # windowManager.dwm.enable = true;
            windowManager.openbox.enable = true;

            # displayManager.session = [
            #   {
            #     manage = "window";
            #     name = "steam";
            #     start = ''
            #       ${pkgs.steam}/bin/steam -steamos -tenfoot &
            #       waitPID=$!
            #     '';
            #   }
            # ];

            videoDrivers = ["nvidia"];
            resolutions = [
              {
                x = 1920;
                y = 1080;
              }
              {
                x = 1280;
                y = 720;
              }
            ];
          };

          # Enable OpenGL
          hardware.graphics = {
            enable = true;
          };

          boot.kernelPackages = pkgs.linuxPackages_6_12;
          boot.blacklistedKernelModules = ["nouveau"];
          hardware.nvidia = {
            open = false;
            modesetting.enable = true;

            nvidiaSettings = true;

            package = config.boot.kernelPackages.nvidiaPackages.beta;
          };
          boot.kernelParams = ["nvidia-drm.modeset=1"];

          services.ollama = {
            enable = true;
            host = "0.0.0.0";
          };

          # Enable the OpenSSH daemon.
          services.openssh.enable = true;

          # Steam
          programs.gamescope = {
            enable = true;
            capSysNice = true;
          };
          programs.steam = {
            enable = true;

            package = pkgs.steam.override {
              extraPkgs = pkgs:
                with pkgs; [
                  xorg.libXcursor
                  xorg.libXi
                  xorg.libXinerama
                  xorg.libXScrnSaver
                  xorg.xinput
                  xorg.xf86inputmouse
                  xorg.xf86inputvmmouse
                  libpng
                  libpulseaudio
                  libvorbis
                  stdenv.cc.cc.lib
                  libkrb5
                  keyutils
                  gamescope-wsi
                  vulkan-loader
                  zenity
                  wayland
                ];
            };

            # gamescopeSession = {
            #   enable = true;

            #   env = {
            #     WLR_NO_HARDWARE_CURSORS = "1";
            # GBM_BACKEND = "nvidia-drm";
            # __GLX_VENDOR_LIBRARY_NAME = "nvidia";
            # };

            # args = [
            # "-w"
            # "1920"
            # "-h"
            # "1080"
            # "-W"
            # "1920"
            # "-H"
            # "1080"
            # "--backend"
            # "drm"
            # "--debug-layers"
            # "--debug-focus"
            # "--synchronous-x11"
            # "--adaptive-sync"
            # "--hdr-enabled"
            # "--rt"
            #     "-b"
            #     "--steam"
            #     "--force-grab-cursor"
            #     "--expose-wayland"
            #   ];

            #   steamArgs = [
            #     "-tenfoot"
            #     "-pipewire"
            #     "-pipewire-dmabuf"
            #     "-steamos"
            #   ];
            # };
          };

          programs.xwayland.enable = true;
          programs.gamemode.enable = true;

          environment.systemPackages = with pkgs; [
            gamescope
            vulkan-loader
            vulkan-tools
            libdrm
            libglvnd
            egl-wayland
            libva
            libva-utils
            # xdg-desktop-portal
            # xdg-desktop-portal-kde
            # xdg-desktop-portal-gnome
            #   # mangohud
            protonup-qt
            #   # lutris
            #   # bottles
            #   # heroic
          ];

          # environment.loginShellInit = ''
          #   [[ "$(tty)" = "/dev/tty1" ]] && ./gs.sh
          # '';

          environment.sessionVariables = {
            # WAYLAND_DISPLAY = "wayland-0";
          };

          # systemd.user.services.xdg-desktop-portal-wlr.serviceConfig.Environment = [
          #   "WAYLAND_DISPLAY=gamescope-0"
          # ];
          # xdg.portal = {
          #   enable = true;
          # wlr = {
          #   enable = true;
          # };
          # };

          services.dbus.enable = true;

          security.rtkit.enable = true;
          services.pipewire = {
            enable = true; # if not already enabled
            alsa.enable = true;
            alsa.support32Bit = true;
            pulse.enable = true;
            wireplumber.enable = true;
            jack.enable = true;
          };

          # Disable firewall (use firewall in router).
          networking.firewall.enable = false;

          users.users.emilbroman = {
            extraGroups = [
              "input"
              "video"
              "seat"
            ];
          };

          home-manager.sharedModules = [
            {
              programs.fish.shellAliases.nix-rebuild = "sudo nixos-rebuild switch --flake ~/code/nix --impure";
            }
          ];
        })
      ];
    };
  };
}
