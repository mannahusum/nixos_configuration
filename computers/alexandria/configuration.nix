({
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
    # ./x11.nix
    ../../modules/acme.nix
    ../../modules/keyboard.nix
    ../../modules/wayland.nix
    ../../modules/sshd.nix
    ../../modules/saned.nix
    ../../modules/nginx.nix
    ../../modules/yubikey.nix
    ../../modules/system_administration/debug.nix
    ../../modules/users.nix
    ./fileshare-classic.nix
    # ./smb-fileserver.nix
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
      extraOptions = ''
        keep-outputs = true
        keep-derivations = true
        experimental-features = nix-command flakes
      '';
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
    systemd.network.links."70-persistent-net-name" = {
      matchConfig.PermanentMACAddress = "70:20:84:06:50:50";
      linkConfig.Name = "eth0";
    };

    # containers.archon = {
    #   privateNetwork = true;
    #   hostBridge = "br0";
    #   localAddress = "192.168.10.251/24";
    #   autoStart = true;
    #   config = { config, pkgs, lib, ... }: {
    #     imports = [
    #       ./active-directory.nix
    #     ];
    #
    #     system.stateVersion = "24.11";
    #
    #     networking = {
    #       firewall = {
    #         enable = true;
    #         allowedTCPPorts = [ 80 ];
    #       };
    #       # Use systemd-resolved inside the container
    #       # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
    #       useHostResolvConf = lib.mkForce false;
    #     };
    #   };
    # };

    networking = {
      interfaces.br0 = {
        # ipv4.addresses = [
        #   {
        #     address = "192.168.10.252";
        #     prefixLength = 24;
        #   }
        # ];
      };
      bridges.br0.interfaces = [
        "eth0"
      ];
      # defaultGateway = {
      #   address = "192.168.0.1";
      #   interface = "br0";
      # };
      hostId = "d22d38ba";
      hostName = "alexandria";
      tempAddresses = "disabled";
      hosts = {
        # "192.168.10.251" = [
        #   "archon.catbertsen.de"
        #   "archon.windows.catbertsen.de"
        #   "archon"
        # ];
        # "192.168.10.252" = [
        #   "alexandria.catbertsen.de"
        #   "alexandria.windows.catbertsen.de"
        #   "alexandria"
        # ];
        # "192.168.10.253" = [
        #   "mannahusum.catbertsen.de"
        # ];
        # "192.168.10.254" = [
        #   "hydra.catbertsen.de"
        #   "calendar.catbertsen.de"
        #   "gitea.catbertsen.de"
        # ];
      };
    };

    services.zfs.autoSnapshot = {
      enable = true;
      flags = "-k -p -u";
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
