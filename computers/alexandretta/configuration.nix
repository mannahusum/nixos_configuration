({
  config,
  disko,
  lanzaboote,
  lib,
  modulesPath,
  nixpkgs-makemkv,
  pkgs,
  sops-nix,
  ...
}: {
  imports = [
    ../disko-config.nix
    disko.nixosModules.disko
    lanzaboote.nixosModules.lanzaboote
    ../../modules/acme.nix
    ../../modules/arm.nix
    ../../modules/backup-server.nix
    ../../modules/postfix.nix
    ../../modules/serial-console.nix
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/base.nix")
    ../shared-config.nix
    ./sops.nix
    sops-nix.nixosModules.sops
  ];

  config = let
    byidpath = name: "/dev/disk/by-id/" + name;
    bootdrive = byidpath "usb-Swissbit_USB_Flash_Drive_601924969200009D-0:0";
    systemdrives = map byidpath ["nvme-Samsung_SSD_990_PRO_1TB_S6Z1NU0XA16328H"];
    storagedrives = map byidpath ["ata-ST14000NM001G-2KJ103_ZL287GM9"];
    localdrives = systemdrives ++ storagedrives;
  in {
    boot = {
      # bootspec.enable = true;
      # loader.systemd-boot.enable = nixpkgs.lib.mkForce false;
      loader.systemd-boot.enable = true;
      lanzaboote = {
        enable = false;
      };
      initrd = {
        availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "sd_mod" "mgag200" "igb" "i2c_i801" "ahci" "mei_me" "intel_pch_thermal" "nvidia"];
      };
      kernelModules = ["kvm-intel"];
      # extraModulePackages = [ config.boot.kernelModules.nvidia ];
    };
    caarm.enable = true;
    caserialconsole.enable = true;
    cadrives = {
      enable = true;
      boot = bootdrive;
      system = systemdrives;
      storage = storagedrives;
      swapsize = "172G";
      l2arcsize = "512G";
      espsize = "1G";
      homesFor = ["christian" "marianne"];
    };
    capostfix = {
      enable = true;
      connection = "smtp.protonmail.ch:587";
      mydomain = "catbertsen.de";
    };
    cabackupserver = {
      enable = true;
      username = "alexandria-backup";
      sshkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIENuJozoOGUX38alQSsfLhXGUQ/bj+LMBYtz4AU4mPJM syncoid@alexandria";
    };
    cawayland = {
      enable = true;
      graphicsSettings = ''
        export WLR_DRM_DEVICES="/dev/dri/$(${pkgs.intel-gpu-tools}/bin/lsgpu | grep 102b:0522 | head -n 1 | cut -d' ' -f1)"
      '';
    };

    systemd.network = {
      enable = true;
      links = {
        "20-persistent-net-name-eth0" = {
          matchConfig.PermanentMACAddress = "00:1e:67:54:25:6c";

          linkConfig.Name = "eth0";
        };
        "20-persistent-net-name-eth1" = {
          matchConfig.PermanentMACAddress = "00:1e:67:54:25:6d";
          linkConfig.Name = "eth1";
        };
        "25-br0" = {
          matchConfig.OriginalName = "br0";
          linkConfig.MACAddressPolicy = "none";
        };
      };
      netdevs = {
        "10-br0" = {
          netdevConfig = {
            Kind = "bridge";
            Name = "br0";
            MACAddress = "none";
          };
        };
      };
      networks = {
        "30-eth0" = {
          matchConfig.Name = "eth0";
          networkConfig.Bridge = "br0";
          linkConfig.RequiredForOnline = "enslaved";
        };
        "30-eth1" = {
          matchConfig.Name = "eth1";
          networkConfig.DHCP = "yes";
          linkConfig.RequiredForOnline = "no";
        };
        "40-br0" = {
          matchConfig.Name = "br0";
          bridgeConfig = {};
          networkConfig = {
            DHCP = "ipv4";
            IPv6AcceptRA = true;
          };
          linkConfig.RequiredForOnline = "routable";
        };
      };
    };

    networking = {
      hostId = "16c516f2";
      hostName = "alexandretta";
      useDHCP = lib.mkDefault true;
      useNetworkd = true;
    };

    services = {
      systembus-notify.enable = true;
      smartd = {
        enable = true;
        autodetect = false;
        devices = map (drive: {device = drive;}) localdrives;
        notifications.systembus-notify.enable = true;
        notifications.mail = {
          enable = true;
          sender = "alexandria@catbertsen.de";
          recipient = "christian@wudika.de";
        };
      };
      fwupd = {
        extraRemotes = ["lvfs-testing"];
        uefiCapsuleSettings.DisableCapsuleUpdateOnDisk = true;
      };
      minidlna = {
        enable = true;
        settings = {
          notify_interval = 60;
          friendly_name = "Alexandretta";
          media_dir = [
            "V,/media/video"
          ];
          inotify = "yes";
        };
        openFirewall = true;
      };
      xserver.videoDrivers = ["nvidia"];
    };
    systemd.services.rasdaemon.path = with pkgs; [
      ipmitool
    ];
    hardware = {
      cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      rasdaemon = {
        enable = true;
        mainboard = ''
          vendor = Intel Corporation
          model = S1200SP
        '';
        config = ''
          PAGE_CE_REFRESH_CYCLE="24H"
          PAGE_CE_THRESHOLD="50"
          PAGE_CE_ACTION="soft"
        '';
        extraModules = ["ie31200_edac"];
      };
      nvidia.open = true;
    };

    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
        ncurses5
        gccNGPackages_15.libstdcxx
        openipmi
      ];
    };
    environment.systemPackages = let
      mkvpkgs = import nixpkgs-makemkv {
        inherit (pkgs.stdenv.hostPlatform) system;
        config.allowUnfreePredicate = pkg:
          builtins.elem (lib.getName pkg) [
            "makemkv"
          ];
      };
    in
      with pkgs; [
        efitools
        fdupes
        ipmitool
        mkvpkgs.makemkv
        # makemkv
        rasdaemon
        sbsigntool
      ];

    system.stateVersion = "25.11";
  };
})
