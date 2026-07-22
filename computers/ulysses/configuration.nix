{
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
    ../disko-config.nix
    ./sops.nix
    sops-nix.nixosModules.sops
  ];

  config = {
    hardware = {
      bluetooth = {
        enable = true;
        powerOnBoot = true;
        settings = {
          General = {
            # Shows battery charge of connected devices on supported
            # Bluetooth adapters. Defaults to 'false'.
            Experimental = true;
            # When enabled other devices can connect faster to us, however
            # the tradeoff is increased power consumption. Defaults to
            # 'false'.
            FastConnectable = true;
          };
          Policy = {
            # Enable all controllers when they are found. This includes
            # adapters present on start as well as adapters that are plugged
            # in later on. Defaults to 'true'.
            AutoEnable = true;
          };
        };
      };
      sensor.iio.enable = true;
      microsoft-surface.kernelVersion = "stable";
    };
    cadrives = {
      enable = true;
      system = ["/dev/disk/by-id/nvme-KBG30ZPZ512G_TOSHIBA_494Y1154YMMS"];
      homesFor = ["christian" "marianne"];
      swapsize = "32G";
      espsize = "1G";
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
      networkmanager.enable = true;
      hostId = "a2d79e48";
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
