{
  config,
  home-manager,
  lib,
  nixpkgs,
  overlays,
  pkgs,
  system,
  ...
}: let
  cfg = config.causers;
in {
  imports = [
    home-manager.nixosModules.home-manager
  ];

  options.causers = {
    adminUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = ["christian"];
      example = ["christian" "marianne"];
      description = ''
        Users with administrative rights on this
        computer, like modifying printers or
        becoming root
      '';
    };

    regularUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      example = ["marianne"];
      description = ''
        Users with access to resources to fully use
        this machine, e.g. acceleration of graphics
        rendering
      '';
    };

    regularUserGroups = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = ["camera" "cdrom" "dialout" "disk" "tty"];
      example = ["cdrom"];
      description = ''
        List of groups to be accessible by regular
        users of the system
      '';
    };

    adminUserGroups = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "docker"
        "kvm"
        "libvirtd"
        "lxd"
        "qemu-libvirtd"
        "render"
        "transmission"
        "video"
        "vboxusers"
        "wheel"
        "networkmanager"
      ];
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
    };
  in {
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
                  "cdrom"
                  "dialout"
                  "docker"
                  "kvm"
                  "libvirtd"
                  "lxd"
                  "qemu-libvirtd"
                  "render"
                  "transmission"
                  "video"
                  "vboxusers"
                  "wheel"
                  "networkmanager"
                ];
              };
          }
        ) ((builtins.attrNames myusers) ++ cfg.adminUsers ++ cfg.regularUsers)
      );

      groups = builtins.listToAttrs (map (
        user: {
          name = user;
          value = {};
        }
      ) (builtins.attrNames myusers));

      mutableUsers = true;
    };

    home-manager = {
      users = {
        christian = import ../home_manager/caHomeConfig.nix {
          inherit config nixpkgs overlays system;
          forwardTo = "${config.users.users.christian.home}/.forwarded-sockets";
          createForwardPath = true;
        };
      };
    };

    security.sudo.wheelNeedsPassword = false;
    nix.settings.trusted-users = ["root" "christian"];
  };
}
