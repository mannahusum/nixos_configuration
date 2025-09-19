# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  boot,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./bootdevice.nix
  ];

  # boot.kernelPackages = pkgs.kernelPackages_custom_tinyconfig_kernel;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.efi = {
    canTouchEfiVariables = false;
    efiSysMountPoint = "/boot/efi";
  };
  boot.loader.grub = {
    enableCryptodisk = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  networking = {
    hostId = "aabbccdd"; # Just something for a temporary computer
  };

  nixpkgs.overlays = [
    (_: prev: {
      prev.linuxPackagesFor = kernel:
        (prev.linuxPackagesFor kernel).extend (_: _: {ati_drivers_x11 = null;});
    })
  ];
}
