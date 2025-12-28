{
  config,
  lib,
  modulesPath,
  overlays,
  pkgs,
  sops-nix,
  ...
}: {
  imports = [
    ../../modules/gitea.nix
    ../../modules/keyboard.nix
    ../../modules/nginx.nix
    (modulesPath + "/profiles/base.nix")
    ../../modules/saned.nix
    ../../modules/sshd.nix
    ../../modules/usermount.nix
    ../../modules/users.nix
    ../../modules/wayland.nix
    ../../modules/xandikos.nix
    ../../modules/yubikey.nix
    ../shared-config.nix
    ./sops.nix
    sops-nix.nixosModules.sops
  ];

  options.hydra = {
  };

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
      extraOptions = ''
        keep-outputs = true
        keep-derivations = true
        experimental-features = nix-command flakes
      '';
      settings = {
        substituters = [
          # "http://mannahusum.catbertsen.de:5000/"
          "https://nix-community.cachix.org"
        ];
        trusted-public-keys = [
          "mannahusum.catbertsen.de:vzQcMgkUCDNjjLkZmSAlpzi9c0qZQEc/hoYz2Qb+PrY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
      };
    };

    services = {
      # r53-ddns = {
      #   zoneID = "Z04260616D6EKM0EH83P";
      #   hostname = "hydra";
      #   environmentFile = config.sops.templates."route53Credentials".path;
      #   enable = true;
      #   domain = "catbertsen.de";
      # };
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
        dnssec = "true";
        domains = ["~."];
        fallbackDns = ["1.1.1.1#one.one.one.one.one" "1.0.0.1#one.one.one.one"];
        dnsovertls = "true";
      };
    };

    casshd.enable = true;
    casaned.enable = true;
    canginx.enable = true;
    caacme = {
      enable = true;
      credentialsfile = config.sops.templates."route53Credentials".path;
    };
    caxandikos = {
      enable = true;
      domain = "calendar.catbertsen.de";
      passwordfile = config.sops.templates."xandikosBasicAuth".path;
    };
    cagitea = {
      enable = true;
      domain = "gitea.catbertsen.de";
    };
    cawayland.enable = true;
    cayubikey.enable = true;
    # environment.etc."sway/config.d/monitors.conf".text = ''
    #   output "DP-1" mode 3840x2160@30Hz pos 0 0
    #   output "HDMI-A-1" mode 1600x1200@60Hz pos 3840 0 scale 0.61
    # '';
    cakeyboard.enable = true;
    time.timeZone = "Europe/Berlin";
    i18n = {
      defaultLocale = "de_DE.UTF-8";
      extraLocaleSettings = {
        LC_COLLATE = "de_DE.UTF-8";
        LC_CTYPE = "de_DE.UTF-8";
      };
    };
    networking = {
      firewall.enable = false;
      nameservers = ["1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one"];
      enableIPv6 = true;
      hostId = "d22d38ba";
      hostName = "hydra";
      tempAddresses = "disabled";
      # interfaces.enp2s0 = {
      #   ipv4.addresses = [
      #     {
      #       address = "192.168.10.254";
      #       prefixLength = 24;
      #     }
      #   ];
      # };
      # defaultGateway = {
      #   address = "192.168.10.1";
      #   interface = "enp2s0";
      # };
      # hosts = {
      #   "192.168.10.253" = [
      #     "mannahusum.catbertsen.de"
      #   ];
      #   "192.168.10.254" = [
      #     "hydra.catbertsen.de"
      #     "calendar.catbertsen.de"
      #     "gitea.catbertsen.de"
      #   ];
      # };

      useHostResolvConf = lib.mkForce false;
    };
    causermount.enable = true;

    environment.systemPackages = with pkgs; [
      git
      mokutil
      sbctl
      tpm2-tss
      git-crypt
      neovim
      ripgrep
      xterm # for resize command
      file
    ];
    system.stateVersion = "23.11";
  };
}
