{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    terminal-stack.url = ../../terminal-stack;
    kubernetes.url = ../../kubernetes;
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    terminal-stack,
    kubernetes,
  }: {
    nixosConfigurations."srv" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        system = "x86_64-linux";

        config.allowUnfree = true;
        config.cudaSupport = true;
        config.cudaCapability = "8.9";
      };

      modules = [
        ./hardware-configuration.nix
        kubernetes.node-module
        home-manager.nixosModules.home-manager
        terminal-stack.system-module
        ./tank.nix
        ({
          config,
          pkgs,
          ...
        }: {
          virtualisation.containerd = {
            enable = true;
            settings = {
              plugins."io.containerd.grpc.v1.cri".containerd = {
                snapshotter = "overlayfs";
              };
            };
          };

          virtualisation.docker.enable = true;

          systemd.network.links."10-lan0" = {
            matchConfig.MACAddress = "58:11:22:cf:22:75";
            linkConfig.Name = "lan0";
          };

          nix.settings.experimental-features = "nix-command flakes";
          nix.settings.download-buffer-size = 524288000;

          system.configurationRevision = self.rev or self.dirtyRev or null;

          networking.hostName = "srv";
          networking.domain = "bb3.site";
          networking.networkmanager.enable = true;
          system.stateVersion = "24.11";

          nix.settings.trusted-users = ["emilbroman"];

          users.users.emilbroman = {
            name = "emilbroman";
            shell = pkgs.fish;
            home = "/home/emilbroman";
            isNormalUser = true;
            linger = true;
            extraGroups = [
              "wheel" # Enable ‘sudo’.
              "input"
              "video"
              "audio"
              "docker"
            ];
          };

          home-manager.backupFileExtension = "old";
          home-manager.useGlobalPkgs = true;

          home-manager.users.emilbroman = {
            imports = [
              terminal-stack.home-module
            ];

            showHostnameInFishPrompt = true;

            home.file.".hushlogin".text = "";

            home.stateVersion = "23.05";

            programs.home-manager.enable = true;

            programs.fish.shellAliases.nix-rebuild = "sudo nixos-rebuild switch --flake ~/code/nix/src/machines/srv";
          };

          # Use the systemd-boot EFI boot loader.
          boot.loader.systemd-boot.enable = true;
          boot.loader.systemd-boot.configurationLimit = 1;
          boot.loader.efi.canTouchEfiVariables = true;
          boot.loader.timeout = 1;

          time.timeZone = "Europe/Stockholm";

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
          };
          programs.gamemode.enable = true;

          environment = {
            systemPackages = with pkgs; [mangohud gamescope gamescope-wsi];
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
            ({lib, ...}: {
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
                    "PROTON_ENABLE_HDR=1"
                    "DXVK_HDR=1"
                  ];
                  ExecStart = ''
                    ${pkgs.gamescope}/bin/gamescope \
                      --adaptive-sync \
                      --hdr-enabled \
                      --rt \
                      --force-grab-cursor \
                      --steam \
                      -w 3840 -h 2160 \
                      -W 2560 -H 1440 \
                      -- \
                      ${pkgs.coreutils}/bin/env PATH=$PATH:${lib.makeBinPath [pkgs.gamemode]} \
                      ${pkgs.steam}/bin/steam -tenfoot -steamos
                  '';
                  Restart = "on-failure";
                };

                Install = {
                  WantedBy = ["drm-session.target"];
                };
              };
            })
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
