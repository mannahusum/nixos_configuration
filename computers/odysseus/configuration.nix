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
    (modulesPath + "/profiles/base.nix")
    ../../modules/postfix.nix
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
    };
    cadrives = {
      enable = true;
      boot = null;
      system = ["/dev/disk/by-id/nvme-KBG30ZPZ512G_TOSHIBA_988Y10GMYMMS"];
      swapsize = "32G";
      espsize = "1G";
      homesFor = ["christian" "marianne"];
    };
    capostfix = {
      enable = true;
      connection = "smtp.protonmail.ch:587";
      mydomain = "wudika.de";
    };

    cawayland = {
      enable = true;
      displayManager = "gdm";
    };

    services = {
      pcscd.enable = true;
    };
    networking = {
      firewall.enable = false;
      hostId = "31c099d4";
      hostName = "odysseus";
      networkmanager.enable = true;
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
    };

    environment.systemPackages = with pkgs; [
      mokutil
    ];
    # environment.etc."sway/config.d/monitors.conf".text = ''
    #   output "DP-1" mode 3840x2160@30Hz pos 0 0
    #   output "HDMI-A-1" mode 1600x1200@60Hz pos 3840 0 scale 0.61
    # '';
    system.stateVersion = "25.11";
  };
}
