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
    ../../modules/pixiecore.nix
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
    nix.buildMachines = [
      {
        hostName = "mini.local";
        sshUser = "christianalbertsen";
        systems = [ "aarch64-darwin" "aarch64-linux" ];
        supportedFeatures = [ "apple-virt" "nixos-test" ];
      }
    ];

    services = {
      r53-ddns = {
        ttl = 3600;
        zoneID = "Z04260616D6EKM0EH83P";
        hostname = "hydra";
        environmentFile = config.sops.templates."route53Credentials".path;
        enable = true;
        domain = "catbertsen.de";
      };
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

    caacme = {
      enable = true;
      credentialsfile = config.sops.templates."route53Credentials".path;
    };
    cagitea = {
      enable = true;
      domain = "gitea.catbertsen.de";
    };
    cakeyboard.enable = true;
    canginx.enable = true;
    capixiecore.enable = true;
    casaned.enable = true;
    casshd.enable = true;
    causermount.enable = true;
    cawayland.enable = true;
    caxandikos = {
      enable = true;
      domain = "calendar.catbertsen.de";
      passwordfile = config.sops.templates."xandikosBasicAuth".path;
    };
    cayubikey.enable = true;
    # environment.etc."sway/config.d/monitors.conf".text = ''
    #   output "DP-1" mode 3840x2160@30Hz pos 0 0
    #   output "HDMI-A-1" mode 1600x1200@60Hz pos 3840 0 scale 0.61
    # '';
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
      hostId = "b800626c";
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

    services.printing = {
      enable = true;
    };
    hardware.printers = {
      ensurePrinters = [
        {
          name = "kyocera5021cdw";
          location = "Yorckstraße 38, Arbeitszimmer";
          deviceUri = "dnssd://Kyocera%20ECOSYS%20P5021cdw._ipp._tcp.local/?uuid=4509a320-0061-004d-0036-0025074fb3d9";
          model = "everywhere";
        }
      ];
      ensureDefaultPrinter = "kyocera5021cdw";
    };

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
