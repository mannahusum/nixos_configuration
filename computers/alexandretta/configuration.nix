({
  lib,
  modulesPath,
  nixpkgs-makemkv,
  overlays,
  pkgs,
  sops-nix,
  system,
  ...
}: {
  imports = [
    sops-nix.nixosModules.sops
    ./sops.nix
    (modulesPath + "/profiles/base.nix")
    ../shared-config.nix
    ../disko-config.nix
    ../../modules/acme.nix
    ../../modules/keyboard.nix
    ../../modules/wayland.nix
    ../../modules/sshd.nix
    ../../modules/saned.nix
    ../../modules/nginx.nix
    ../../modules/yubikey.nix
    ../../modules/system_administration/debug.nix
    ../../modules/users.nix
    ./fileshare-classic.nix
    # ./smb-fileserver.nix
  ];

  config = {
    cadrives = {
      enable = true;
      boot = "/dev/disk/by-id/usb-Swissbit_USB_Flash_Drive_601924969200009D-0:0";
      system = ["/dev/disk/by-id/nvme-Samsung_SSD_990_PRO_1TB_S6Z1NU0XA16328H"];
      storage = ["/dev/disk/by-id/ata-ST14000NM001G-2KJ103_ZL287GM9"];
      swapsize = "172G";
      l2arcsize = "512G";
      espsize = "1G";
      homesFor = ["christian" "marianne"];
    };
    boot = {
      supportedFilesystems = ["zfs"];
      loader.efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      initrd = {
        supportedFilesystems = ["zfs"];
        systemd = {
          enable = true;
          emergencyAccess = true;
        };
      };
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
    nix = {
      settings = {
        substituters = [
          "https://nix-community.cachix.org"
        ];
        trusted-public-keys = [
          "mannahusum.catbertsen.de:vzQcMgkUCDNjjLkZmSAlpzi9c0qZQEc/hoYz2Qb+PrY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
      };
    };
    services.minidlna = {
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

    # containers.regina = {
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
      hostId = "16c516f2";
      hostName = "alexandretta";
      tempAddresses = "disabled";
    };

    services.zfs.autoSnapshot = {
      enable = true;
      flags = "-k -p -u";
    };

    environment.systemPackages = let
      mkvpkgs = import nixpkgs-makemkv {
        inherit system;
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
        ipmitool
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
