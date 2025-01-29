({
  config,
  modulesPath,
  lib,
  pkgs,
  sops-nix,
  ...
}: {
  imports = [
    sops-nix.nixosModules.sops
    ./sops.nix
    (modulesPath + "/profiles/base.nix")
    # ./x11.nix
    ../../modules/keyboard.nix
    ../../modules/wayland.nix
    ../../modules/sshd.nix
    ../../modules/saned.nix
    ../../modules/nginx.nix
    ../../modules/xandikos.nix
    ../../modules/gitea.nix
    ../../modules/yubikey.nix
    ../../modules/users.nix
    ../../modules/usermount.nix
  ];

  options.hydra = {
  };

  config = {
    disko.devices = import ./disko-config.nix {
      inherit lib;
    };
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "google-chrome"
      ];
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
      hostId = "d22d38ba";
      hostName = "hydra";
      tempAddresses = "disabled";
      hosts = {
        "192.168.10.253" = [
          "mannahusum.catbertsen.de"
        ];
        "192.168.10.254" = [
          "hydra.catbertsen.de"
          "calendar.catbertsen.de"
          "gitea.catbertsen.de"
        ];
      };
    };
    causermount.enable = true;

    environment.systemPackages = [
      pkgs.git
      pkgs.mokutil
      pkgs.sbctl
      pkgs.tpm2-tss
      pkgs.git-crypt
      pkgs.neovim
      pkgs.ripgrep
      pkgs.xterm # for resize command
      pkgs.file
    ];
    system.stateVersion = "23.11";
  };
})
