{
  disko,
  lanzaboote,
  lib,
  modulesPath,
  nixos-hardware,
  nixpkgs,
  pkgs,
  sops-nix,
  ...
}: {
  imports = [
    disko.nixosModules.disko
    ../disko-config.nix
    lanzaboote.nixosModules.lanzaboote
    ../../modules/keyboard.nix
    (modulesPath + "/profiles/base.nix")
    ../../modules/postfix.nix
    ../../modules/sshd.nix
    ../../modules/usermount.nix
    ../../modules/users.nix
    ../../modules/wayland.nix
    ../../modules/yubikey.nix
    nixos-hardware.nixosModules.microsoft-surface-pro-intel
    ../shared-config.nix
    ./sops.nix
    sops-nix.nixosModules.sops
  ];

  config = {
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
    cadrives = {
      enable = true;
      boot = null;
      system = ["/dev/disk/by-id/nvme-KBG30ZPZ512G_TOSHIBA_494Y1154YMMS"];
      swapsize = "32G";
      espsize = "1G";
      homesFor = ["christian" "marianne"];
    };
    capostfix = {
      enable = true;
      connection = "smtp.protonmail.ch:587";
      mydomain = "wudika.de";
    };

    casshd.enable = true;
    cawayland = {
      enable = true;
      displayManager = "gdm";
    };
    causermount.enable = true;
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
    services = {
      pcscd.enable = true;
      printing = {
        enable = true;
        drivers = with pkgs; [
          canon-cups-ufr2
        ];
      };
    };
    networking = {
      enableIPv6 = true;
      firewall.enable = false;
      hostId = "a2d79e48";
      hostName = "ulysses";
      nameservers = ["1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one"];
      networkmanager.enable = true;
      useHostResolvConf = lib.mkForce false;
    };

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
      # printers = {
      #   ensurePrinters = [
      #     {
      #       name = "canon";
      #       location = "Ginsterweg 12, Arbeitszimmer";
      #       deviceUri = "socket";
      #       model = "everywhere";
      #     }
      #   ];
      #   ensureDefaultPrinter = "kyocera5021cdw";
      # };
    };

    environment.systemPackages = with pkgs; [
      git
      sbctl
      tpm2-tss
      git-crypt
      neovim
      ripgrep
      xterm # for resize command
      file
    ];
    # environment.etc."sway/config.d/monitors.conf".text = ''
    #   output "DP-1" mode 3840x2160@30Hz pos 0 0
    #   output "HDMI-A-1" mode 1600x1200@60Hz pos 3840 0 scale 0.61
    # '';
    system.stateVersion = "25.11";
  };
}
