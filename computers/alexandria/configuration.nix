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
    disko.nixosModules.disko
    ../disko-config.nix
    ./fileshare-classic.nix
    lanzaboote.nixosModules.lanzaboote
    ../../modules/acme.nix
    ../../modules/backup-client.nix
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
    ./sops.nix
    sops-nix.nixosModules.sops
  ];

  config = let
    byidpath = name: "/dev/disk/by-id/" + name;
    systemdrives = map byidpath [
      "nvme-WD_BLACK_SN850X_2000GB_24196D800798"
      "nvme-WD_BLACK_SN850X_2000GB_24196D800851"
    ];
    storagedrives = map byidpath [
      "ata-ST14000NM001G-2KJ103_ZL2AV9NN"
      "ata-ST14000NM001G-2KJ103_ZL2BAQXD"
      "ata-ST14000NM001G-2KJ103_ZL2DA7SJ"
    ];
  in {
    boot = {
      bootspec.enable = true;
      loader.systemd-boot.enable = nixpkgs.lib.mkForce false;
      lanzaboote = {
        enable = true;
        pkiBundle = "/etc/secureboot";
      };
      supportedFilesystems = ["zfs"];
      loader.efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      initrd = {
        availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "sd_mod" "amdgpu"];
        kernelModules = ["amdgpu"];
        supportedFilesystems = ["zfs"];
        systemd = {
          enable = true;
          emergencyAccess = true;
        };
      };
      kernelModules = ["kvm-amd"];
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
      boot = null;
      system = systemdrives;
      storage = storagedrives;
      swapsize = "172G";
      l2arcsize = "0";
      espsize = "1G";
      homesFor = ["christian" "marianne"];
    };
    capostfix = {
      enable = true;
      connection = "smtp.protonmail.ch:587";
      mydomain = "wudika.de";
    };

    cabackupclient = {
      enable = true;
      serverAddress = "alexandretta.local";
      serverHostkey = ../alexandretta/extra-files/etc/ssh/ssh_host_ed25519_key.pub;
      remoteUser = "${config.networking.hostName}-backup";
      remotePath = "tank/backup/alexandria";
      dataSets = ["tank/media"];
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

    services = {
      systembus-notify.enable = true;
      smartd = {
        enable = true;
        autodetect = false;
        devices = map (drive: { device = drive; }) (systemdrives ++ storagedrives);
        notifications.systembus-notify.enable = true;
        notifications.mail = {
          enable = true;
          sender = "alexandria@wudika.de";
          recipient = "christian@wudika.de";
        };
      };

      xserver.videoDrivers = ["amdgpu"];
      resolved = {
        enable = true;
      };
    };
    systemd.network = {
      enable = true;
      links = {
        "20-persistent-net-name-eth0" = {
          matchConfig.PermanentMACAddress = "70:20:84:06:50:50";
          linkConfig.Name = "eth0";
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
        "40-br0" = {
          matchConfig.Name = "br0";
          bridgeConfig = {};
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
      enableIPv6 = true;
      hostId = "d22d38ba";
      hostName = "alexandria";
      nameservers = ["1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one"];
      tempAddresses = "disabled";
      useDHCP = lib.mkDefault true;
      useHostResolvConf = lib.mkForce false;

      useNetworkd = true;
    };

    services.minidlna = {
      enable = true;
      settings = {
        notify_interval = 60;
        friendly_name = "Alexandria";
        media_dir = [
          "V,/media/video"
        ];
        inotify = "yes";
      };
      openFirewall = true;
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
        file
        git
        git-crypt
        mkvpkgs.makemkv
        neovim
        ripgrep
        sbctl
        tpm2-tss
        vulkan-validation-layers
        xterm # for resize command
      ];

    system.stateVersion = "23.11";
  };
})
