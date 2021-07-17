# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ nixpkgs, config, pkgs, ... }:
{
  imports =
    [
      ./music.nix
      ./bootdevice.nix
      ./hardware-configuration.nix
    ];

  # Use the GRUB 2 boot loader.
  boot = {
    supportedFilesystems = [
      "ntfs"
      "zfs"
    ];
    zfs = {
      enableUnstable = true;
      requestEncryptionCredentials = true;
    };
    initrd = {
      postDeviceCommands = "mount";
    };
    loader = {
      grub = {
        enable = true;
        version = 2;
        efiSupport = true;
        enableCryptodisk = true;
        efiInstallAsRemovable = true;
      };
      efi = {
        efiSysMountPoint = "/boot/efi";
        canTouchEfiVariables = false;
      };
    };
    kernelModules = [
      "coretemp"
    ];
  };

  networking = {
    hostId = "90c8ec86";
    hostName = "mannahusum"; # Define your hostname.

    useDHCP = false;
    interfaces = {
      enp0s25.useDHCP = true;
      wlan0.useDHCP = true;
    };
  };

  boot.blacklistedKernelModules = [ "i926" ];

  services = {
    thinkfan = {
      enable = true;
      smartSupport = true;
      sensors = [
        {
          type = "tpacpi";
          query = "/proc/acpi/ibm/thermal";
        }

      ];
      fans = [
        {
          type = "tpacpi";
          query = "/proc/acpi/ibm/fan";
        }
      ];
      # sensors = ''
      #   tp_thermal /proc/acpi/ibm/thermal (0,0,0,0,0,0,0,0)
      #   hwmon /sys/class/hwmon/hwmon4/temp1_input (0)
      #   atasmart /dev/disk/by-id/wwn-0x57c354817e8ac175 (15)
      #   # atasmart /dev/disk/by-id/wwn-0x5000c5009d522fb3 (15)
      #   atasmart /dev/disk/by-id/wwn-0x5001b448bb115a46 (15)
      # '';
    };
    geoclue2 = {
      enable = true;
      enableWifi = true;
    };
  };

  hardware.bluetooth.enable = true;

  environment.systemPackages = with pkgs; [
    pciutils
  ];
}
