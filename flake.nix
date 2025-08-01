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

          services.caddy.virtualHosts."sunshine.home.emilbroman.me".extraConfig = ''
            reverse_proxy https://10.0.0.4:47990 {
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

          services.getty.autologinUser = "emilbroman";

          # Enable OpenGL
          hardware.graphics = {
            enable = true;
          };

          # NVIDIA stuff...
          boot.kernelPackages = pkgs.linuxPackages_6_12;
          boot.blacklistedKernelModules = ["nouveau" "amdgpu"];
          services.xserver.videoDrivers = ["nvidia" "amdgpu"];
          hardware.nvidia = {
            open = false;
            modesetting.enable = true;
            nvidiaSettings = true;
            package = config.boot.kernelPackages.nvidiaPackages.beta;
          };
          boot.kernelParams = [
            "nvidia-drm.modeset=1"

            "drm.edid_firmware=HDMI-A-1:edid/edid.bin"
          ];

          hardware.firmware = [
            (
              pkgs.runCommand "edid.bin" {compressFirmware = false;} ''
                mkdir -p $out/lib/firmware/edid
                cp ${./lg-oled55b6v-hdmi.edid} $out/lib/firmware/edid/edid.bin
              ''
            )
          ];

          # Steam
          programs.steam = {
            enable = true;
            gamescopeSession.enable = true;
          };
          programs.xwayland.enable = true;

          programs.gamescope = {
            enable = true;
            capSysNice = true;
          };

          users.users.emilbroman = {
            linger = true;
            extraGroups = [
              "input"
              "video"
              "audio"
            ];
          };

          environment = {
            systemPackages = with pkgs; [mangohud];
            loginShellInit = "systemctl --user start drm-session.target";
          };

          services.sunshine = {
            enable = true;
            capSysAdmin = true;
            autoStart = true;
          };

          home-manager.sharedModules = [
            {
              home.file.".config/sunshine/apps.json".text = builtins.toJSON {
                env = {};
                apps = [
                  {
                    name = "Steam";
                    detached = [
                      "setsid steam steam://open/bigpicture"
                    ];
                    image-path = "steam.png";
                  }
                ];
              };
            }
            {
              systemd.user.targets.drm-session = {
                Unit.Description = "TTY + DRM";
              };

              systemd.user.services.steam = {
                Unit = {
                  Description = "Steam in Gamescope with HDR and Metrics";
                  After = ["graphical.target" "systemd-user-sessions.service" "dev-dri-card0.device" "sunshine.service"];
                  Wants = ["graphical.target" "sunshine.service"];
                  Requires = ["sunshine.service"];
                };

                Service = {
                  Environment = [
                    "MANGOHUD=0"
                    "MANGOHUD_CONFIG=cpu_temp,gpu_temp,ram,vram"
                  ];
                  ExecStart = ''
                    ${pkgs.gamescope}/bin/gamescope \
                      --adaptive-sync \
                      --hdr-enabled \
                      --rt \
                      --steam \
                      -w 3840 -h 2160 \
                      -W 2560 -H 1440 \
                      -- ${pkgs.steam}/bin/steam -tenfoot -steamos
                  '';
                  Restart = "on-failure";
                };

                Install = {
                  WantedBy = ["drm-session.target"];
                };
              };
            }
            {
              programs.fish.shellAliases.nix-rebuild = "sudo nixos-rebuild switch --flake ~/code/nix --impure";
            }
          ];

          security.rtkit.enable = true;
          services.pipewire = {
            enable = true;
            alsa.enable = true;
            alsa.support32Bit = true;
            pulse.enable = true;
            jack.enable = true;
            wireplumber.enable = true;
          };

          # Ollama
          services.ollama = {
            enable = true;
            host = "0.0.0.0";
          };

          # Enable the OpenSSH daemon.
          services.openssh.enable = true;

          # Disable firewall (use firewall in router).
          networking.firewall.enable = false;
        })
      ];
    };
  };
}
