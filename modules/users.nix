{ config, pkgs, lib, modulesPath, ssh-keys, ... }:
let
  cfg = config.causers;
in {

  options.causers = {
    adminUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "christian" ];
      example = [ "christian" "marianne" ];
      description = ''
        Users with administrative rights on this
        computer, like modifying printers or
        becoming root
      '';
    };

    regularUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "marianne" ];
      description = ''
        Users with access to resources to fully use
        this machine, e.g. acceleration of graphics
        rendering
      '';
    };

    regularUserGroups = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "camera" "cdrom" "dialout" "disk" ];
      example = [ "cdrom" ];
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
    groupsToUsers =
      users:
      groups:
      builtins.listToAttrs (
        map (
          user:
          { name = user; value = { extraGroups = groups; }; }
        )
        users
      );
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
        openssh.authorizedKeys.keyFiles = [
          # The keys are the same for any system type
          ssh-keys.packages."x86_64-linux".ssh_public_keys.out
        ];
      };
    };
  in {

    users.users = builtins.listToAttrs (map (
      user:
      {
        name = user;
        value =
          (if (builtins.hasAttr user myusers) then (builtins.getAttr user myusers) else {}) //
          {
            extraGroups =
              (if ("extraGroups"?myusers."$user") then myusers."$user".extraGroups else [])
              ++ (if (builtins.elem user cfg.adminUsers) then cfg.adminUserGroups else [])
              ++ (if (builtins.elem user (cfg.adminUsers ++ cfg.regularUsers)) then cfg.regularUserGroups else []);
          };
      }
    ) ((builtins.attrNames myusers) ++ cfg.adminUsers ++ cfg.regularUsers));

    users.groups = builtins.listToAttrs (map (
      user:
      { name = user; value = {}; }
    ) (builtins.attrNames myusers));
    # users.users.christian.extraGroups = cfg.regularUserGroups ++ cfg.adminUserGroups;
    # Option definitions.
    # Define what other settings, services and resources should be active.
    # Usually these are depend on whether a user of this module chose to "enable" it
    # using the "option" above.
    # You also set options here for modules that you imported in "imports".
    security.sudo.wheelNeedsPassword = false;
    nix.settings.trusted-users = [ "root" "christian" ];
    users.mutableUsers = true;
    # users.users.marianne.isNormalUser = true;
    programs.gnupg.agent.enable = true;
  };
}
