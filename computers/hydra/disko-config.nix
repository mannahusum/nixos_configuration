{ disks ? [ "/dev/disk/by-id/nvme-eui.0025385811b168ce" "/dev/disk/by-id/wwn-0x5001b448bc1f7726" ], swapsize ? "72G", ... }: {
  disk = let
    disklayout = device: efimountpoint: counter: {
      device = device;
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
          rpool = {
            size = "100%";
            content = {
              type = "luks";
              name = "rpool${counter}";
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
  in {
    vda = (disklayout (builtins.elemAt disks 0) "/boot" "0");
    vdb = (disklayout (builtins.elemAt disks 1) "/efibackup" "1");
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
  };
}
