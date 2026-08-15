({
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
    disko.nixosModules.disko
    ../disko-config.nix
    ./fileshare-classic.nix
    lanzaboote.nixosModules.lanzaboote
    ../../modules/acme.nix
    ../../modules/arm.nix
    ../../modules/backup-server.nix
    ../../modules/dlna.nix
    ../../modules/postfix.nix
    ../../modules/keyboard.nix
    ../../modules/nginx.nix
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/base.nix")
    ../../modules/postfix.nix
    ../../modules/saned.nix
    ../../modules/sshd.nix
    ../../modules/users.nix
    ../../modules/wayland.nix
    ../../modules/yubikey.nix
    ../shared-config.nix
    # ./smb-fileserver.nix
    ./sops.nix
    sops-nix.nixosModules.sops
  ];

  config = let
    byidpath = name: "/dev/disk/by-id/" + name;
    bootdrive = byidpath "usb-Swissbit_USB_Flash_Drive_601924969200008C-0:0";
    systemdrives = map byidpath [
      "nvme-Lexar_SSD_NM620_2TB_QBS830R004175P1125"
      "nvme-Lexar_SSD_NM620_2TB_QBS830R000758P1125"
    ];
    storagedrives = map byidpath [
      "ata-ST14000NM001G-2KJ103_ZL28WN0G"
      "ata-ST14000NM001G-2KJ103_ZL2E4EBQ"
      "ata-ST14000NM001G-2KJ103_ZL2E4HML"
      "ata-ST14000NM001G-2KJ103_ZL2EFR06"
    ];
  in {
    boot = {
      bootspec.enable = true;
      loader.systemd-boot.enable = nixpkgs.lib.mkForce false;
      lanzaboote = {
        enable = true;
      };
      supportedFilesystems = ["zfs"];
      loader.efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      initrd = {
        availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "sd_mod" "mgag200" "igb" "i2c_i801" "ahci" "mei_me" "ie31200_edac" "intel_pch_thermal" "nvidia"];
        supportedFilesystems = ["zfs"];
        systemd = {
          enable = true;
          emergencyAccess = true;
        };
      };
      kernelModules = ["kvm-intel"];
      kernelParams = [
        "console=ttyS0,115200"
      ];
      swraid = {
        enable = true;
        mdadmConf = ''
          MAILADDR christian@wudika.de
        '';
      };
    };
    caarm = {
      enable = true;
      name = "Ulpia";
    };
    cadrives = {
      enable = true;
      boot = bootdrive;
      system = systemdrives;
      storage = storagedrives;
      swapsize = "172G";
      l2arcsize = "1024G";
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
      username = "ulpia-backup";
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
          matchConfig.PermanentMACAddress = "00:1e:67:54:16:8a";
          linkConfig.Name = "eth0";
        };
        "20-persistent-net-name-eth1" = {
          matchConfig.PermanentMACAddress = "00:1e:67:54:16:8b";
          linkConfig.Name = "eth1";
        };
        "25-br0" = {
          matchConfig.OriginalName = "br0";
          linkConfig.MACAddressPolicy = "none";
        };
      };
      netdevs = {
        "10-br0" = {
          bridgeConfig = {
            STP = false;
            MulticastSnooping = false;
          };
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
          bridgeConfig = {
            MulticastRouter = "permanent";
          };
          networkConfig = {
            DHCP = "ipv4";
            IPv6AcceptRA = true;
            MulticastDNS = true;
          };
          linkConfig.RequiredForOnline = "routable";
        };
      };
    };

    networking = {
      hostId = "d22d38ba";
      hostName = "ulpia";
      useDHCP = lib.mkDefault true;
      useNetworkd = true;
    };

    services = {
      systembus-notify.enable = true;
      smartd = {
        enable = true;
        autodetect = false;
        devices = map (drive: {device = drive;}) (systemdrives ++ storagedrives);
        notifications.systembus-notify.enable = true;
        notifications.mail = {
          enable = true;
          sender = "ulpia@catbertsen.de";
          recipient = "christian@wudika.de";
        };
      };
      fwupd = {
        extraRemotes = ["lvfs-testing"];
        uefiCapsuleSettings.DisableCapsuleUpdateOnDisk = true;
      };
      xserver.videoDrivers = ["nvidia"];
      zfs.autoSnapshot = {
        enable = true;
        flags = "-k -p -u";
      };
    };
    cadlna = {
      enable = true;
      name = "Ulpia";
      nvidiaAccelerationPath = "/dev/dri/by-path/pci-0000:01:00.0-render";
    };
    users.groups.media.members = [ "christian" "marianne" "jellyfin" ];
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
    environment.systemPackages =
      with pkgs; [
        efitools
        fdupes
        git-crypt
        ipmitool
        makemkv
        neovim
        rasdaemon
        ripgrep
        sbctl
        sbsigntool
        tpm2-tss
        xterm # for resize command
      ];

    system.stateVersion = "23.11";
  };
})
