{
  disks ? ["/dev/disk/by-id/nvme-KBG30ZPZ512G_TOSHIBA_988Y10GMYMMS"],
  swapsize ? "32G",
  ...
}: {
  disk = let
    disklayout = device: efimountpoint: counter: {
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
              type = "swap";
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
  in {
    vda = disklayout (builtins.elemAt disks 0) "/boot" 0;
  };
  zpool = {
    rpool = {
      type = "zpool";
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
        "home/christian" = {
          type = "zfs_fs";
          mountpoint = "/home/christian";
        };
        "home/marianne" = {
          type = "zfs_fs";
          mountpoint = "/home/marianne";
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
