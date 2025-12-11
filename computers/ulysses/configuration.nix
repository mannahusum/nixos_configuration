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
    ../../modules/keyboard.nix
    (modulesPath + "/profiles/base.nix")
    ../../modules/sshd.nix
    ../../modules/usermount.nix
    ../../modules/users.nix
    ../../modules/wayland.nix
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
    cawayland = {
      enable = true;
      displayManager = "gdm";
    };
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
      hostName = "ulysses";

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
    system.stateVersion = "25.11";
  };
}
