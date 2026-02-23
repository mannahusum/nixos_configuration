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
    ../disko-config.nix
    ../../modules/serial-console.nix
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

  config = let 
    localdrives = ["nvme-Samsung_SSD_970_EVO_Plus_2TB_S4J4NX0R847857X" "ata-SanDisk_SSD_PLUS_2000GB_213705800853"];
  in {
    caserialconsole.enable = true;
    cadrives = {
      enable = true;
      boot = null;
      system = localdrives;
      storage = [];
      swapsize = "72G";
      l2arcsize = "0";
      espsize = "1G";
      homesFor = ["christian" "marianne"];
    };
    services.systembus-notify.enable = true;
    services.smartd = {
      enable = true;
      autodetect = false;
      devices = map (drivename: { device="/dev/disk/by-id/"+drivename; }) localdrives;
      notifications.systembus-notify.enable = true;
      notifications.mail = {
        enable = true;
        sender = "hydra@catbertsen.de";
        recipient = "christian@wudika.de";
      };
    };
    services.postfix = {
      enable = true;
      settings.main = {
        myorigin = "catbertsen.de";
        mydomain = "catbertsen.de";
        mydestination = null;
        inet_interfaces = "loopback-only";
        local_recipient_maps = null;
        local_transport = "error:local mail delivery is disabled";
        myhostname = "${config.networking.hostName}.catbertsen.de";
        relayhost = ["smtp.protonmail.ch:587"];
        smtp_sasl_auth_enable = true;
        smtp_generic_maps = "regexp:${config.sops.templates.protonmail_from_rewrite.path}";
        smtp_sasl_password_maps = "texthash:${config.sops.templates.protonmail_login.path}";
        smtp_sasl_security_options = "noanonymous";
        smtp_tls_security_level = "encrypt";
        local_header_rewrite_clients = "static:all";
        append_dot_mydomain = true;
        smtputf8_enable = false;
      };
    };
    nixpkgs = {
      inherit overlays;
      config.allowUnfreePredicate = pkg:
        builtins.elem (lib.getName pkg) [
          "google-chrome"
        ];
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
    environment.etc."sysconfig/lm_sensors" = {
      text = ''
        # Generated by sensors-detect on Fri Feb 20 01:13:56 2026
        # This file is sourced by /etc/init.d/lm_sensors and defines the modules to
        # be loaded/unloaded.
        #
        # The format of this file is a shell script that simply defines variables:
        # HWMON_MODULES for hardware monitoring driver modules, and optionally
        # BUS_MODULES for any required bus driver module (for example for I2C or SPI).

        HWMON_MODULES="nct6775"
      '';
      user = "root";
      mode = "0644";
    };

    environment.systemPackages = with pkgs; [
      git
      lm_sensors
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
