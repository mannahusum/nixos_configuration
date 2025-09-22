({
  config,
  modulesPath,
  lib,
  pkgs,
  sops-nix,
  nixpkgs,
  system,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/base.nix")
    ../modules/keyboard.nix
    ../modules/wayland.nix
    ../modules/sshd.nix
    ../modules/saned.nix
    ../modules/nginx.nix
    ../modules/xandikos.nix
    ../modules/gitea.nix
    ../modules/yubikey.nix
    ../modules/users.nix
    ../modules/usermount.nix
  ];

  config = {
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
          "https://nix-community.cachix.org"
        ];
        trusted-public-keys = [
          "mannahusum.catbertsen.de:vzQcMgkUCDNjjLkZmSAlpzi9c0qZQEc/hoYz2Qb+PrY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
      };
    };

    services = {
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
    cawayland.enable = true;
    cayubikey.enable = true;
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
      tempAddresses = "disabled";
      hosts = {
        "192.168.10.252" = [
          "alexandria.windows.catbertsen.de"
          "alexandria.catbertsen.de"
          "alexandria"
        ];
        "192.168.10.253" = [
          "mannahusum.catbertsen.de"
          "mannahusum"
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
