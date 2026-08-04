{
  config,
  disko,
  lanzaboote,
  lib,
  modulesPath,
  nixpkgs,
  pkgs,
  sops-nix,
  ...
}: {
  imports = [
    lanzaboote.nixosModules.lanzaboote
    disko.nixosModules.disko
    (modulesPath + "/installer/scan/not-detected.nix")
    sops-nix.nixosModules.sops
    ./sops.nix
    (modulesPath + "/profiles/base.nix")
    ../disko-config.nix
    ../shared-config.nix
    ../../modules/acme.nix
    ../../modules/gitea.nix
    ../../modules/keyboard.nix
    ../../modules/nginx.nix
    ../../modules/pixiecore.nix
    ../../modules/postfix.nix
    ../../modules/saned.nix
    ../../modules/serial-console.nix
    ../../modules/sshd.nix
    ../../modules/usermount.nix
    ../../modules/users.nix
    ../../modules/wayland.nix
    ../../modules/xandikos.nix
    ../../modules/yubikey.nix
  ];

  options.hydra = {
  };

  config = let
    byidpath = name: "/dev/disk/by-id/" + name;
    localdrives = map byidpath ["nvme-Samsung_SSD_970_EVO_Plus_2TB_S4J4NX0R847857X" "ata-SanDisk_SSD_PLUS_2000GB_213705800853"];
  in {
    boot = {
      bootspec.enable = true;
      loader.systemd-boot.enable = nixpkgs.lib.mkForce false;
      lanzaboote = {
        enable = true;
        pkiBundle = "/etc/secureboot";
      };
      initrd = {
        availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "sd_mod" "amdgpu"];
        kernelModules = ["amdgpu"];
        systemd.enable = true;
      };
      kernelModules = ["kvm-amd"];
      extraModulePackages = [];
    };

    # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
    # (the default) this is the recommended approach. When using systemd-networkd it's
    # still possible to use this option, but it's recommended to use it in conjunction
    # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
    # networking.interfaces.enp2s0.useDHCP = lib.mkDefault true;
    # networking.interfaces.wlo1.useDHCP = lib.mkDefault true;

    caacme = {
      enable = true;
      credentialsfile = config.sops.templates."route53Credentials".path;
    };
    cagitea = {
      enable = true;
      domain = "gitea.catbertsen.de";
    };
    cakeyboard.enable = true;
    canginx.enable = true;
    capixiecore.enable = true;
    capostfix = {
      enable = true;
      connection = "smtp.protonmail.ch:587";
      mydomain = "catbertsen.de";
    };
    casaned.enable = true;
    caserialconsole.enable = true;
    casshd.enable = true;
    causermount.enable = true;
    cawayland.enable = true;
    caxandikos = {
      enable = true;
      domain = "calendar.catbertsen.de";
      passwordfile = config.sops.templates."xandikosBasicAuth".path;
    };
    cayubikey.enable = true;

    cadrives = {
      enable = true;
      boot = null;
      system = localdrives;
      storage = [];
      swapsize = "72G";
      l2arcsize = "0";
      espsize = "1G";
      homesFor = ["christian" "marianne"];
    };
    services = {
      xserver.videoDrivers = ["amdgpu"];
      systembus-notify.enable = true;
      smartd = {
        enable = true;
        autodetect = false;
        devices = map (drive: {device = drive;}) localdrives;
        notifications.systembus-notify.enable = true;
        notifications.mail = {
          enable = true;
          sender = "hydra@catbertsen.de";
          recipient = "christian@wudika.de";
        };
      };
    };
    nix.buildMachines = [
      {
        hostName = "mini.local";
        sshUser = "christianalbertsen";
        systems = ["aarch64-darwin" "aarch64-linux"];
        supportedFeatures = ["apple-virt" "nixos-test"];
      }
    ];

    services = {
      r53-ddns = {
        ttl = 3600;
        zoneID = "Z04260616D6EKM0EH83P";
        hostname = "hydra";
        environmentFile = config.sops.templates."route53Credentials".path;
        enable = true;
        domain = "catbertsen.de";
      };
      avahi = {
        enable = true;
        nssmdns4 = true;
        nssmdns6 = true;
        publish = {
          enable = true;
          userServices = true;
          hinfo = true;
        };
        ipv6 = true;
      };
      pcscd.enable = true;
      resolved = {
        enable = true;
      };
      printing = {
        enable = true;
      };
    };

    time.timeZone = "Europe/Berlin";
    i18n = {
      defaultLocale = "de_DE.UTF-8";
      extraLocaleSettings = {
        LC_COLLATE = "de_DE.UTF-8";
        LC_CTYPE = "de_DE.UTF-8";
      };
    };
    networking = {
      enableIPv6 = true;
      firewall.enable = false;
      hostId = "b800626c";
      hostName = "hydra";
      nameservers = ["1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one"];
      tempAddresses = "disabled";
      useDHCP = lib.mkDefault true;
      useHostResolvConf = lib.mkForce false;
    };

    hardware = {
      cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      graphics = {
        enable = true;
        extraPackages = with pkgs; [
          libvdpau-va-gl
        ];
        extraPackages32 = with pkgs; [
          driversi686Linux.libvdpau-va-gl
        ];
      };
      printers = {
        ensurePrinters = [
          {
            name = "kyocera5021cdw";
            location = "Yorckstraße 38, Arbeitszimmer";
            deviceUri = "dnssd://Kyocera%20ECOSYS%20P5021cdw._ipp._tcp.local/?uuid=4509a320-0061-004d-0036-0025074fb3d9";
            model = "everywhere";
          }
        ];
        ensureDefaultPrinter = "kyocera5021cdw";
      };
    };
    environment = {
      systemPackages = with pkgs; [
        file
        git
        git-crypt
        lm_sensors
        mokutil
        neovim
        ripgrep
        sbctl
        sbsigntool
        tpm2-tss
        vulkan-validation-layers
        xterm # for resize command
      ];
      variables = {
        WLR_RENDERER = "vulkan";
      };
      etc."sysconfig/lm_sensors" = {
        text = ''
          # Generated by sensors-detect on Fri Feb 20 01:13:56 2026
          # This file is sourced by /etc/init.d/lm_sensors and defines the modules to
          # be loaded/unloaded.
          #
          # The format of this file is a shell script that simply defines variables:
          # HWMON_MODULES for hardware monitoring driver modules, and optionally
          # BUS_MODULES for any required bus driver module (for example for I2C or SPI).

          HWMON_MODULES="nct6775"
        '';
        user = "root";
        mode = "0644";
      };
    };

    system.stateVersion = "23.11";
  };
}
