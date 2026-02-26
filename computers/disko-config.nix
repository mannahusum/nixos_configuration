{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.cadrives;
in {
  options.cadrives = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to use my general way of partitioning
      '';
    };
    boot = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Drive to be used as the boot drive or null, if it isn't used
      '';
    };
    system = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = ''
        The drives being used for for system installation
      '';
    };
    storage = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = ''
        Drives used for additional storage or archival
      '';
    };
    swapsize = lib.mkOption {
      type = lib.types.strMatching "[0-9]+[KMGTP]?";
      default = "0";
      description = ''
        Size of the swap partition
      '';
    };
    l2arcsize = lib.mkOption {
      type = lib.types.strMatching "[0-9]+[KMGTP]?";
      default = "0";
      description = ''
        Reserve space for l2arc of storage on system drives
      '';
    };
    espsize = lib.mkOption {
      type = lib.types.strMatching "[0-9]+[KMGTP]?";
      default = "1G";
      description = ''
        Size of boot partition if there is no dedicated drive
      '';
    };
    homesFor = lib.mkOption {
      # type = lib.types.attrsOf lib.types.strMatching "^[a-z_]([a-z0-9_-]{0,31}|[a-z0-9_-]{0,30}\$)$";
      type = lib.types.listOf (lib.types.strMatching "^[a-z_]([a-z0-9_-]{0,31}|[a-z0-9_-]{0,30}\$)$");
      default = [];
      description = ''
        List of users for which to create home drives
      '';
    };
  };

  config = let
    swapviamdraid = (builtins.length cfg.system) > 1;
  in
    lib.mkIf cfg.enable {
      nixpkgs.config.packageOverrides = pkgs: {
        zfsStable = pkgs.zfsStable.override {
          enableMail = true;
        };
      };

      boot = {
        supportedFilesystems = ["zfs"];
        loader.efi = {
          canTouchEfiVariables = true;
          efiSysMountPoint = "/boot";
        };
        initrd = {
          supportedFilesystems = ["zfs"];
          systemd = {
            enable = true;
            emergencyAccess = true;
            initrdBin = with pkgs; [
              gptfdisk
            ];
          };
        };
        swraid = lib.mkIf swapviamdraid {
          enable = true;
          mdadmConf = ''
            MAILADDR christian@wudika.de
          '';
        };
      };

      services = {
        zfs = {
          autoScrub.enable = true;
          zed = {
            enableMail = true;
            settings = {
              ZED_EMAIL_ADDR = [ "christian@wudika.de" ];
              ZED_NOTIFY_VERBOSE = true;
            };
          };
        };
      };

      disko.devices = {
        disk = let
          bootlayout = device: {
            inherit device;
            type = "disk";
            content = {
              type = "gpt";
              partitions = {
                ESP = {
                  size = "100%";
                  type = "EF00";
                  content = {
                    type = "filesystem";
                    format = "vfat";
                    mountpoint = "/boot";
                  };
                };
              };
            };
          };
          nvmelayout = device: efimountpoint: swapviamdraid: counter: {
            inherit device;
            type = "disk";
            content = {
              type = "gpt";
              partitions = lib.mkMerge [
                (lib.mkIf (efimountpoint != null) {
                  ESP = {
                    size = cfg.espsize;
                    type = "EF00";
                    content = {
                      type = "filesystem";
                      format = "vfat";
                      mountpoint = efimountpoint;
                    };
                  };
                })
                {
                  swap = {
                    size = cfg.swapsize;
                    content =
                      if swapviamdraid
                      then {
                        type = "mdraid";
                        name = "swap";
                      }
                      else {
                        type = "swap";
                      };
                  };
                  l2arc = lib.mkIf ((cfg.l2arcsize != "0") && (builtins.length cfg.storage > 0)) {
                    size = cfg.l2arcsize;
                    content = {
                      type = "luks";
                      name = "l2arc${builtins.toString counter}";
                      initrdUnlock = true;
                      passwordFile = "/tmp/secret.key";
                      settings.allowDiscards = true;
                    };
                  };
                  rpool = {
                    size = "100%";
                    content = {
                      type = "luks";
                      name = "rpool${builtins.toString counter}";
                      initrdUnlock = true;
                      passwordFile = "/tmp/secret.key";
                      settings.allowDiscards = true;
                      content = {
                        type = "zfs";
                        pool = "rpool";
                      };
                    };
                  };
                }
              ];
            };
          };
          rotatinglayout = device: counter: {
            inherit device;
            type = "disk";
            content = {
              type = "gpt";
              partitions = {
                tank = {
                  size = "100%";
                  content = {
                    type = "luks";
                    name = "tank${builtins.toString counter}";
                    passwordFile = "/tmp/secret.key";
                    initrdUnlock = true;
                    settings.allowDiscards = true;
                    content = {
                      type = "zfs";
                      pool = "tank";
                    };
                  };
                };
              };
            };
          };
          efimountpoint = counter:
            if cfg.boot != null
            then null
            else if counter == 0
            then "/boot"
            else if (builtins.length cfg.system) == 2
            then "/efibackup"
            else "efibackup${counter - 1}";
        in
          lib.mkMerge [
            (lib.mkIf (cfg.boot != null) {boot = bootlayout cfg.boot;})
            (lib.lists.foldl' (a: b: a // b) {} (lib.lists.imap0 (i: v: {"nvme${toString i}" = nvmelayout "${v}" (efimountpoint i) swapviamdraid i;}) cfg.system))
            (lib.lists.foldl' (a: b: a // b) {} (lib.lists.imap0 (i: v: {"rotating${toString i}" = rotatinglayout "${v}" i;}) cfg.storage))
          ];
        mdadm = lib.mkIf swapviamdraid {
          swap = {
            type = "mdadm";
            level = 1;
            metadata = "1.0";
            content = {
              type = "swap";
            };
          };
        };
        zpool = {
          rpool = {
            type = "zpool";
            mode =
              if builtins.length cfg.system == 1
              then ""
              else "mirror";
            options = {
              ashift = "13";
            };
            rootFsOptions = {
              compression = "lz4";
              "com.sun:auto-snapshot" = "false";
              mountpoint = "none";
              xattr = "sa";
              acltype = "posixacl";
              atime = "off";
              relatime = "off";
              dedup = "on";
            };
            postCreateHook = "zfs snapshot rpool@blank";

            datasets =
              lib.lists.foldl' (a: b: a // b)
              {
                root = {
                  type = "zfs_fs";
                  options.mountpoint = "none";
                };
                "root/nixos" = {
                  type = "zfs_fs";
                  options = {
                    mountpoint = "legacy";
                    "com.sun:auto-snapshot" = "false";
                  };
                  mountpoint = "/";
                };
                home = {
                  type = "zfs_fs";
                  mountpoint = "/home";
                };
                reserved = {
                  type = "zfs_fs";
                  options = {
                    refreservation = "1G";
                    mountpoint = "none";
                  };
                };
              }
              (lib.lists.forEach (lib.lists.unique cfg.homesFor) (username: {
                "home/${username}" = {
                  type = "zfs_fs";
                  mountpoint = "/home/${username}";
                };
              }));
          };
          tank = let
            smbShare = mountpoint: {
              inherit mountpoint;
              type = "zfs_fs";
              options = {
                mountpoint = "legacy";
                "com.sun:auto-snapshot" = "false";
              };
            };
          in
            lib.mkIf (builtins.length cfg.storage > 0) {
              type = "zpool";
              mode =
                if builtins.length cfg.storage == 1
                then ""
                else if builtins.length cfg.storage == 2
                then "mirror"
                else "raidz1";
              options = {
                ashift = "13";
              };
              rootFsOptions = {
                compression = "lz4";
                "com.sun:auto-snapshot" = "false";
                mountpoint = "none";
                xattr = "sa";
                acltype = "posixacl";
                atime = "off";
                relatime = "off";
                dedup = "on";
              };
              postCreateHook = "zfs snapshot tank@blank";

              datasets = {
                media = {
                  type = "zfs_fs";
                  options.mountpoint = "none";
                };
                vms = {
                  type = "zfs_fs";
                  options.mountpoint = "none";
                };
                "media/audio" = smbShare "/media/audio";
                "media/games" = smbShare "/media/games";
                "media/games/wii" = smbShare "/media/games/wii";
                "media/images" = smbShare "/media/images";
                "media/onqm" = smbShare "/media/onqm";
                "media/software" = smbShare "/media/software";
                "media/ultrastar" = smbShare "/media/ultrastar";
                "media/video" = smbShare "/media/video";
                "media/arm" = {
                  type = "zfs_fs";
                  options = {
                    mountpoint = "legacy";
                    "com.sun:auto-snapshot" = "false";
                  };
                };
                "backup" = {
                  type = "zfs_fs";
                  options = {
                    mountpoint = "none";
                    "com.sun:auto-snapshot" = "false";
                  };
                };

                reserved = {
                  type = "zfs_fs";
                  options = {
                    refreservation = "10G";
                    mountpoint = "none";
                  };
                };
              };
            };
        };
      };
    };
}
