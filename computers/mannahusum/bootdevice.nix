  { boot, swapDevices, ... }:

  {
    boot = {
      initrd = {
        secrets = {
          "/keyfileZfs.bin" = "/etc/keys/keyfileZfs.bin";
          "/keyfileSwap.bin" = "/etc/keys/keyfileSwap.bin";
          "/keyfileBoot.bin" = "/etc/keys/keyfileBoot.bin";
        };
        luks.devices = {
    "mannassdboot" = {
      # preLVM = true;
      keyFile = "/keyfileBoot.bin";
      allowDiscards = true;
      device = "/dev/disk/by-uuid/fcf837ac-43ba-4d30-b046-3098534c0833";
    };
    "mannaspinboot0" = {
      # preLVM = true;
      keyFile = "/keyfileBoot.bin";
      allowDiscards = true;
      device = "/dev/disk/by-uuid/e86bfe83-69c1-48f7-802c-bd20fc4b9352";
    };
    "mannaspinboot1" = {
      # preLVM = true;
      keyFile = "/keyfileBoot.bin";
      allowDiscards = true;
      device = "/dev/disk/by-uuid/5b8b41a8-2ac6-4dc5-952a-f1971c630433";
    };
        };
      };
      loader.grub= {
        devices = [
          "/dev/disk/by-id/ata-TS512GMTS430S_F417990005"
          # "nodev"
        ]; # or "nodev" for efi only

        mirroredBoots = [
          {
            devices = [
              "/dev/disk/by-id/ata-SanDisk_SDSSDH3_2T00_203482800038"
            ];
            path = "/boot0";
            efiBootloaderId="NixOS-backup-0";
            efiSysMountPoint="/boot0/efi";
          }

          {
            devices = [
              "/dev/disk/by-id/ata-SanDisk_SDSSDH3_2T00_203482800102"
            ];
            path = "/boot1";
            efiBootloaderId="NixOS-backup-1";
            efiSysMountPoint="/boot1/efi";
          }

        ];
      };
    };
    swapDevices = [
      {
        device = "/dev/disk/by-uuid/ae137b13-9f0f-4b57-97fe-c178780129d6";
        encrypted = {
          enable = true;
          keyFile = "/keyfileSwap.bin";
          label = "mannassdswap";
          blkDev = "/dev/disk/by-uuid/c697d716-3a68-417e-919a-69fd35a373aa";
        };
      }
    ];
  }
