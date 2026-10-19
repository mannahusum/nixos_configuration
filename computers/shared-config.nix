{
  modulesPath,
  lib,
  overlays,
  pkgs,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/base.nix")
    ./shared-config-combined.nix
    ../modules/gitea.nix
    ../modules/keyboard.nix
    ../modules/nginx.nix
    ../modules/saned.nix
    ../modules/sshd.nix
    ../modules/usermount.nix
    ../modules/users.nix
    ../modules/wayland.nix
    ../modules/xandikos.nix
    ../modules/yubikey.nix
  ];

  config = {
    nixpkgs = {
      inherit overlays;
      config = {
        allowUnfreePredicate = pkg:
          builtins.elem (lib.getName pkg) [
            "canon-cups-ufr2"
            "filebot"
            "google-chrome"
            "makemkv"
            "nrf-command-line-tools"
            "nrf-udev"
            "nvidia-settings"
            "nvidia-x11"
            "segger-jlink"
            "unrar"
          ];
        permittedInsecurePackages = [
          "segger-jlink-qt4-874"
        ];
        segger-jlink.acceptLicense = true;
      };
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

    services = {
      avahi = {
        enable = true;
        nssmdns4 = false;
        nssmdns6 = false;
        openFirewall = true;
        publish = {
          enable = true;
          addresses = true;
          workstation = true;
          userServices = true;
          hinfo = true;
        };
        ipv6 = true;
      };
      fwupd = {
        enable = true;
      };
      resolved = {
        enable = true;
        settings.Resolve = {
          DNSStubListenerExtra = "[::1]:53";
          DNSOverTLS = "true";
          DNSSEC = "true";
          Domains = ["~."];
          FallbackDNS = ["1.1.1.1#one.one.one.one.one" "1.0.0.1#one.one.one.one"];
          LLMNR = "true";
          MulticastDNS = "resolve";
        };
      };
    };

    casshd.enable = true;
    cawayland.enable = true;
    cayubikey.enable = true;
    cakeyboard.enable = true;
    i18n = {
      defaultLocale = "de_DE.UTF-8";
      extraLocaleSettings = {
        LC_COLLATE = "de_DE.UTF-8";
        LC_CTYPE = "de_DE.UTF-8";
      };
    };
    networking = {
      enableIPv6 = true;
      tempAddresses = "disabled";
      nameservers = ["1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one"];
      useHostResolvConf = lib.mkForce false;
    };
    causermount.enable = true;

    hardware.graphics.enable = true;

    programs = {
      bat.enable = true;
      cdemu.enable = true;
      direnv = {
        enableBashIntegration = true;
        nix-direnv.enable = true;
      };
      flashprog.enable = true;
      fuse.enable = true;
      git.enable = true;
      iotop.enable = true;
      java = {
        binfmt = true;
        enable = true;
      };
      less.enable = true;
      minipro.enable = true;
      nix-index = {
        enableBashIntegration = true;
      };
      screen.enable = true;
      tcpdump.enable = true;
      vivid = {
        enable = true;
        theme = "solarized-dark";
      };
      yazi = {
        enable = true;
      };
      # zoom-us.enable = true;
    };

    environment.systemPackages = with pkgs; [
      psmisc
      sbctl
      tpm2-tools
    ];
  };
}
