({
  config,
  disko,
  lanzaboote,
  lib,
  modulesPath,
  nixpkgs,
  nixpkgs-makemkv,
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
    ../shared-config.nix
    ../disko-config.nix
    ../../modules/acme.nix
    ../../modules/keyboard.nix
    ../../modules/postfix.nix
    ../../modules/wayland.nix
    ../../modules/sshd.nix
    ../../modules/saned.nix
    ../../modules/nginx.nix
    ../../modules/yubikey.nix
    # ../../modules/system_administration/debug.nix
    ../../modules/users.nix
    ./fileshare-classic.nix
    # ./smb-fileserver.nix
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
        availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "sd_mod" "mgag200" "igb" "i2c_i801" "ahci" "mei_me" "ie31200_edac" "intel_pch_thermal"];
        supportedFilesystems = ["zfs"];
        systemd = {
          enable = true;
          emergencyAccess = true;
        };
      };
      kernelModules = ["kvm-intel"];
      extraModulePackages = [];
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
    nix = {
      settings = {
        substituters = [
          # "https://hydra.catbertsen.de:5000/"
          # "http://mannahusum.catbertsen.de:5000/"
          "https://nix-community.cachix.org"
        ];
        trusted-public-keys = [
          "mannahusum.catbertsen.de:vzQcMgkUCDNjjLkZmSAlpzi9c0qZQEc/hoYz2Qb+PrY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
      };
    };
    casshd.enable = true;
    cawayland.enable = true;
    # cayubikey.enable = true;
    cakeyboard.enable = true;
    time.timeZone = "Europe/Berlin";
    i18n = {
      defaultLocale = "de_DE.UTF-8";
      extraLocaleSettings = {
        LC_COLLATE = "de_DE.UTF-8";
        LC_CTYPE = "de_DE.UTF-8";
      };
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

    # containers.rex = {
    #   privateNetwork = true;
    #   hostBridge = "br0";
    #   localAddress = "192.168.10.251/24";
    #   autoStart = true;
    #   config = { config, pkgs, lib, ... }: {
    #     imports = [
    #       ./active-directory.nix
    #     ];
    #
    #     system.stateVersion = "24.11";
    #
    #     networking = {
    #       firewall = {
    #         enable = true;
    #         allowedTCPPorts = [ 80 ];
    #       };
    #       # Use systemd-resolved inside the container
    #       # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
    #       useHostResolvConf = lib.mkForce false;
    #     };
    #   };
    # };

    networking = {
      enableIPv6 = true;
      hostId = "d22d38ba";
      hostName = "ulpia";
      nameservers = ["1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one"];
      tempAddresses = "disabled";
      useDHCP = lib.mkDefault true;
      useHostResolvConf = lib.mkForce false;

      useNetworkd = true;
    };

    hardware = {
      cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      graphics = {
        enable = true;
      };
    };
    services = {
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
      minidlna = {
        enable = true;
        settings = {
          notify_interval = 60;
          friendly_name = "Ulpia";
          media_dir = [
            "V,/media/video"
          ];
          inotify = "yes";
        };
        openFirewall = true;
      };
      zfs.autoSnapshot = {
        enable = true;
        flags = "-k -p -u";
      };
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
        file
        git
        git-crypt
        mkvpkgs.makemkv
        neovim
        ripgrep
        sbctl
        sbsigntool
        tpm2-tss
        xterm # for resize command
      ];

    system.stateVersion = "23.11";
    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
        ncurses5
        gccNGPackages_15.libstdcxx
        openipmi
      ];
    };
  };
})
