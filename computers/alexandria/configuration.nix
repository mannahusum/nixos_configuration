({
  config,
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
    ../../modules/acme.nix
    ../../modules/backup-client.nix
    ../../modules/keyboard.nix
    ../../modules/wayland.nix
    ../../modules/sshd.nix
    ../../modules/saned.nix
    ../../modules/nginx.nix
    ../../modules/yubikey.nix
    ../../modules/users.nix
    ./fileshare-classic.nix
  ];

  config = {
    disko.devices = import ./disko-config.nix {
      inherit lib;
    };
    nixpkgs = {
      inherit overlays;
      config.allowUnfreePredicate = pkg:
        builtins.elem (lib.getName pkg) [
          "google-chrome"
        ];
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

    # services.jellyfin = {
    #   enable = true;
    #   openFirewall = true;
    # };
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

    services.resolved = {
      enable = true;
      dnssec = "true";
      domains = ["~."];
      fallbackDns = ["1.1.1.1#one.one.one.one.one" "1.0.0.1#one.one.one.one"];
      dnsovertls = "true";
      llmnr = "resolve";
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
      hostId = "d22d38ba";
      hostName = "alexandria";
      tempAddresses = "disabled";
      nameservers = ["1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one"];
      enableIPv6 = true;
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
        git
        mokutil
        sbctl
        tpm2-tss
        git-crypt
        neovim
        ripgrep
        xterm # for resize command
        file
        mkvpkgs.makemkv
      ];

    system.stateVersion = "23.11";
  };
})
