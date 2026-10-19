{
  config,
  disko,
  lanzaboote,
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
    ../../modules/embeddeddev.nix
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
    caembedded = {
      enable = true;
      sshKey = "/etc/ssh/ssh_host_ed25519_key";
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

    causers = {
      desktop = true;
      ui = true;
    };

    services = {
      pcscd.enable = true;
      printing = {
        enable = true;
        drivers = with pkgs; [
          canon-cups-ufr2
        ];
      };
      fwupd = {
        enable = true;
      };
    };
    networking = {
      firewall.enable = false;
      hostId = "31c099d4";
      hostName = "odysseus";
      networkmanager = {
        enable = true;
        ensureProfiles = {
          environmentFiles = [
            config.sops.secrets."networks/variables".path
          ];
          profiles = {
            Ginsterweg12Lorenzen = {
              connection = {
                id = "Ginsterweg12Lorenzen";
                password = "$Ginsterweg12Lorenzen";
                type = "wifi";
              };
            };
          };
        };
      };
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

    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
      };
    };
    programs.virt-manager.enable = true;
    virtualisation.spiceUSBRedirection.enable = true;
    users.groups.libvirtd.members = ["christian"];
    users.groups.kvm.members = ["christian"];
    environment.systemPackages = with pkgs; [
      gnome-boxes
      dnsmasq
      phodav
      dos2unix
      gcab
      surface-control
      wimlib
    ];
    system.stateVersion = "25.11";
  };
}
