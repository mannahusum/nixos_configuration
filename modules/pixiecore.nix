{
  config,
  lib,
  nixpkgs,
  nixos-anywhere,
  home-manager,
  nixos-luks-yk,
  overlays,
  sops-nix,
  ...
}: let
  cfg = config.capixiecore;
in {
  imports = [];

  options.capixiecore = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether giteo should be running on this server
      '';
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 64172;
      example = 65533;
      description = ''
        status-port used by pixiecore
      '';
    };
    statusPort = lib.mkOption {
      type = lib.types.port;
      default = 64172;
      example = 65533;
      description = ''
        status-port used by pixiecore
      '';
    };
  };

  config = let
    sys = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({
          config,
          pkgs,
          lib,
          modulesPath,
          overlays,
          ...
        }: {
          imports = [
            (modulesPath + "/installer/netboot/netboot-minimal.nix")
            # ./users.nix
          ];
          config = {
            nixpkgs = {
              inherit overlays;
              config.allowUnfreePredicate = pkg:
                builtins.elem (lib.getName pkg) [
                  "google-chrome"
                  "unrar"
                ];
            };

            environment.systemPackages = with pkgs; [
              cifs-utils
              curl
              dnf4
              fatresize
              ipmitool
              multipath-tools
              neovim
              nixos-anywhere.packages."${system}".nixos-anywhere
            ];

            services = {
              openssh = {
                enable = true;
                extraConfig = ''
                  PermitUserEnvironment yes
                  StreamLocalBindUnlink yes
                  AcceptEnv PROXMOX_*
                  Match LocalPort 8922
                    ChrootDirectory /mnt/target
                    SetEnv PATH="/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin"
                '';

                settings = {
                  X11Forwarding = true;
                };

                ports = [22 8922];
                openFirewall = true;
              };

              xserver.xkb = {
                model = "pc105";
                variant = "neo,,";
                options = ",,";
              };
            };

            boot = {
              growPartition = true;
              kernelParams = ["console=ttyS0"];
              loader = {
                systemd-boot.enable = true;
                efi.canTouchEfiVariables = true;
                systemd-boot.netbootxyz.enable = false;
              };
            };

            networking = {
              hostName = "installer"; # Define your hostname.
              networkmanager.enable = true;
              wireless.enable = false;
            };

            time.timeZone = "Europe/Berlin";

            i18n.defaultLocale = "en_US.UTF-8";

            console = {
              font = "Lat2-Terminus16";

              colors = [
                "002b36"
                "dc322f"
                "859900"
                "b58900"
                "268bd2"
                "d33682"
                "2aa198"
                "eee8d5"
                "002b36"
                "cb4b16"
                "586e75"
                "657b83"
                "839496"
                "6c71c4"
                "93a1a1"
                "fdf6e3"
              ];

              packages = with pkgs; [
                terminus_font
              ];

              keyMap = "neo";
              # useXkbConfig = true;
            };

            nix = {
              package = pkgs.nixVersions.stable;
              settings = {
                experimental-features = "nix-command flakes";
                trusted-public-keys = [
                  "christian_albertsen:jXedjCfSkY5K3HXhvawGge0MqUyCH6SN1J7FE8wejs8="
                ];
              };
            };

            systemd.services."serial-getty@ttyS1" = {
              enable = true;
              wantedBy = ["getty.target"]; # to start at boot
              serviceConfig.Restart = "always"; # restart when session is closed
            };

            # Enable the OpenSSH daemon.

            users.users.root.openssh.authorizedKeys.keys = pkgs.testing_all_ssh_public_keys;

            system.stateVersion = config.system.nixos.release;
          };
        })
      ];
      specialArgs = {
        inherit home-manager nixos-luks-yk nixpkgs overlays sops-nix;
        system = "x86_64-linux";
      };
    };
  in
    lib.mkIf cfg.enable {
      services.pixiecore = let
        build = sys.config.system.build;
      in {
        cmdLine = "init=${build.toplevel}/init loglevel=4";
        debug = true;
        dhcpNoBind = true;
        enable = true;
        initrd = "${build.netbootRamdisk}/initrd";
        kernel = "${build.kernel}/bzImage";
        mode = "boot";
        openFirewall = true;
        port = cfg.port;
        statusPort = cfg.statusPort;
      };
    };
}
