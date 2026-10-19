{
  config,
  home-manager,
  lib,
  nixpkgs,
  overlays,
  pkgs,
  ...
}: let
  cfg = config.causers;
in {
  imports = [
    home-manager.nixosModules.home-manager
  ];

  options.causers = {
    users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = ["christian"];
      example = ["marianne"];
      description = ''
        The users who will be able to login on this machine
      '';
    };

    defaultPinentry = lib.mkOption {
      type = lib.types.enum ["bemenu" "gnome3"];
      default = "bemenu";
      example = "gnome";
      description = ''
        Default pinentry to be used by the home-manager configuration,
        depending on desktopManager and therefore displayManager
      '';
    };

    ui = lib.mkEnableOption "Install a graphical user interface";
    desktop = lib.mkEnableOption "Install the packages only needed for desktop computers";

    filebotLicense = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      example = "null";
      description = ''
        Path to a license file for filebot
      '';
    };
  };

  config = let
    myusers = {
      christian = {
        initialHashedPassword = "$y$j9T$jug3Q9mus229sFQGQbkC6/$w/pJzFFXGRvpjW6/sck2P8DPo.PJvE4rVbobNaf2yWC";
        createHome = true;
        group = "christian";
        description = "Christian Albertsen";
        home = "/home/christian";
        isNormalUser = true;
        uid = 1005;
        subUidRanges = [
          {
            count = 65536;
            startUid = 65536;
          }
        ];
        subGidRanges = [
          {
            count = 65536;
            startGid = 65536;
          }
        ];
        packages = with pkgs; [
          dash
          coreutils-full
        ];
        openssh.authorizedKeys.keys = pkgs.al_public_keys;
      };
      marianne = {
        createHome = true;
        group = "marianne";
        description = "Marianne Lorenzen";
        home = "/home/marianne";
        isNormalUser = true;
        uid = 1006;
        packages = with pkgs; [
          coreutils-full
        ];
      };
    };
  in
    lib.mkMerge [
      (lib.mkIf (lib.strings.hasSuffix "-linux" pkgs.stdenv.hostPlatform.system) {
        users = {
          users = builtins.listToAttrs (
            map (
              user: {
                name = user;
                value =
                  (
                    if (builtins.hasAttr user myusers)
                    then (builtins.getAttr user myusers)
                    else {}
                  )
                  // {
                    extraGroups = [
                      "audio"
                      "cdrom"
                      "dialout"
                      "disk"
                      "docker"
                      "kvm"
                      "libvirtd"
                      "lxd"
                      "qemu-libvirtd"
                      "render"
                      "transmission"
                      "tss"
                      "video"
                      "vboxusers"
                      "wheel"
                      "networkmanager"
                    ];
                  };
              }
            )
            cfg.users
          );

          groups = builtins.listToAttrs (map (
            user: {
              name = user;
              value = {};
            }
          ) (builtins.attrNames myusers));

          mutableUsers = true;
        };

        home-manager.users =
          (lib.optionalAttrs (builtins.elem "christian" cfg.users) {
            christian = lib.mkMerge [
              (import ../home_manager/caHomeConfig.nix {
                inherit config nixpkgs overlays;
                inherit (cfg) desktop filebotLicense ui;
                system_type = pkgs.stdenv.hostPlatform.system;
                pinentry = cfg.defaultPinentry;
                forwardTo = "${config.users.users.christian.home}/.forwarded-sockets";
                createForwardPath = true;
              })
              {
                home.stateVersion = "26.05";
              }
            ];
          })
          // (lib.optionalAttrs (builtins.elem "marianne" cfg.users) {
            marianne = {
              nixpkgs = {
                inherit overlays;
                system = pkgs.stdenv.hostPlatform.system;
                config.allowUnfreePredicate = pkg:
                  builtins.elem (nixpkgs.lib.getName pkg) [
                    "google-chrome"
                    "makemkv"
                    "unrar"
                  ];
              };
              home = {
                packages = with pkgs; [
                  alacritty
                  google-chrome
                  gscan2pdf
                  libreoffice
                  nautilus
                  neovide
                  sane-backends
                  thunderbird
                  weasis
                ];
                stateVersion = "26.05";
              };
            };
          });

        security.sudo.wheelNeedsPassword = false;
        nix.settings.trusted-users = ["root" "christian"];
      })
      {
        users.users.root.openssh.authorizedKeys.keys = pkgs.testing_all_ssh_public_keys;
      }
    ];
}
