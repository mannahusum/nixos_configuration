{ boot, ... }:

{
  boot = {
    initrd.luks.devices."##CRYPT_BOOT_DEV##" = {
      # preLVM = true;
      keyFile = "/keyfileBoot.bin";
      allowDiscards = true;
    };
    loader.grub.devices = [ "##INSTALL_DEVICE##" ]; # or "nodev" for efi only
  };
}
