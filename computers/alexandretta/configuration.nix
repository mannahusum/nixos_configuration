({
  lib,
  modulesPath,
  nixpkgs-makemkv,
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
    ../../modules/arm.nix
    ../../modules/backup-server.nix
    ../../modules/keyboard.nix
    ../../modules/nginx.nix
    ../../modules/postfix.nix
    ../../modules/saned.nix
    ../../modules/serial-console.nix
    ../../modules/sshd.nix
    ../../modules/usermount.nix
    ../../modules/users.nix
    ../../modules/wayland.nix
    ../../modules/yubikey.nix
  ];

  config = let
    byidpath = name: "/dev/disk/by-id/" + name;
    bootdrive = byidpath "usb-Swissbit_USB_Flash_Drive_601924969200009D-0:0";
    systemdrives = map byidpath ["nvme-Samsung_SSD_990_PRO_1TB_S6Z1NU0XA16328H"];
    storagedrives = map byidpath ["ata-ST14000NM001G-2KJ103_ZL287GM9"];
    localdrives = systemdrives++storagedrives;
  in {
    caarm.enable = true;
    cabackupserver = {
      enable = true;
      username = "alexandria-backup";
      sshkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIENuJozoOGUX38alQSsfLhXGUQ/bj+LMBYtz4AU4mPJM syncoid@alexandria";
    };
    cakeyboard.enable = true;
    capostfix = {
      enable = true;
      connection = "smtp.protonmail.ch:587";
      mydomain = "catbertsen.de";
    };
    caserialconsole.enable = true;
    casshd.enable = true;
    causermount.enable = true;
    cawayland.enable = true;
    # cayubikey.enable = true;

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
    services.systembus-notify.enable = true;
    services.smartd = {
      enable = true;
      autodetect = false;
      devices = map (drive: { device = drive; }) localdrives;
      notifications.systembus-notify.enable = true;
      notifications.mail = {
        enable = true;
        sender = "alexandria@catbertsen.de";
        recipient = "christian@wudika.de";
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
      tempAddresses = "disabled";
    };

    services = {
      fwupd = {
        enable = true;
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
        fdupes
        file
        git
        git-crypt
        ipmitool
        mkvpkgs.makemkv
        neovim
        rasdaemon
        ripgrep
        sbctl
        sbsigntool
        tpm2-tss
        xterm # for resize command
      ];

    system.stateVersion = "25.11";
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
