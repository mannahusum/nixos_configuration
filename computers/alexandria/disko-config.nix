{
  nvme ? ["/dev/disk/by-id/nvme-WD_BLACK_SN850X_2000GB_24196D800798" "/dev/disk/by-id/nvme-WD_BLACK_SN850X_2000GB_24196D800851"],
  rotating ? ["/dev/disk/by-id/ata-ST14000NM001G-2KJ103_ZL2AV9NN" "/dev/disk/by-id/ata-ST14000NM001G-2KJ103_ZL2BAQXD" "/dev/disk/by-id/ata-ST14000NM001G-2KJ103_ZL2DA7SJ"],
  swapsize ? "172G",
  ...
}: {
  disk = let
    nvmelayout = device: efimountpoint: counter: {
      inherit device;
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = efimountpoint;
            };
          };
          swap = {
            size = swapsize;
            content = {
              type = "mdraid";
              name = "swap";
            };
          };
          l2arc = {
            size = "1024G";
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
        };
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
  in {
    nvme0 = nvmelayout (builtins.elemAt nvme 0) "/boot" 0;
    nvme1 = nvmelayout (builtins.elemAt nvme 1) "/efibackup" 1;
    rotating0 = rotatinglayout (builtins.elemAt rotating 0) 0;
    rotating1 = rotatinglayout (builtins.elemAt rotating 1) 1;
    rotating2 = rotatinglayout (builtins.elemAt rotating 2) 2;
  };
  mdadm = {
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
      mode = "mirror";
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

      datasets = {
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
      };
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
    in {
      type = "zpool";
      mode = "raidz1";
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
            refreservation = "1G";
            mountpoint = "none";
          };
        };
      };
    };
  };
}
