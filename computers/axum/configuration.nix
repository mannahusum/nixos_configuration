{
  # config,
  disko,
  lib,
  modulesPath,
  pkgs,
  overlays,
  sops-nix,
  ...
}: {
  imports = [
    # (modulesPath + "/installer/sd-card/sd-image.nix")
    (modulesPath + "/profiles/base.nix")
    ../../modules/sshd.nix
    ../../modules/postfix.nix
    ../../modules/embeddeddev.nix
    ../../modules/users.nix
    ../../modules/wayland.nix
    ../shared-config.nix
    sops-nix.nixosModules.sops
    disko.nixosModules.disko
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

    systemd.services.systemd-vconsole-setup.enable = false;
    systemd.services.reload-systemd-vconsole-setup.enable = false;
    boot = {
      plymouth = {
        enable = false;
        # theme = "bgrt";
      };
      consoleLogLevel = lib.mkDefault 7;
      initrd = {
        allowMissingModules = true;
        systemd = {
          enable = true;
          extraBin = {
            cryptsetup = "${pkgs.cryptsetup}/bin/cryptsetup";
          };
          emergencyAccess = true;
        };
      };
      kernelParams = [
        "8250.nr_uarts=1"
        # "console=tty1"
        # "console=ttyS0,115200n8"
        "quiet"
        "vt.global_cursor_default=0"
        "rd.break"
      ];
      kernelModules = [
        "drm_shmem_helper" # Memory allocator helper required for early ARM buffers
        "hid_generic" # Fallback keyboard driver layout
        "pcie_brcmstb" # Broadcom PCIe controller (Powers the Pi 4 USB chip)
        "reset-raspberrypi" # Broadcom Power/Reset management (Prevents USB lockup)
        "simpledrm" # <-- Ensure early fallback driver explicitly stays bundled
        "usbhid" # Standard USB Keyboard/Mouse driver (Crucial for input)
        "v3d" # Graphics Engine
        "vc4" # Full GPU driver
        "xhci_pci" # USB 3.0 / Host controller driver
      ];
      loader = {
        grub.enable = false;
        generic-extlinux-compatible.enable = true;
      };
    };

    casshd.enable = true;
    causers = {
      users = ["christian"];
      defaultPinentry = "bemenu";
      desktop = false;
      ui = true;
    };
    cawayland.enable = true;
    disko.devices = {
      disk = {
        main = {
          type = "disk";
          device = "/dev/disk/by-id/mmc-SH32G_0x92efc831";
          content = {
            type = "gpt";
            partitions = {
              FIRMWARE = {
                priority = 1;
                type = "EF00";
                size = "200M";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = ["nofail"];
                };
              };
              luks = {
                size = "100%";
                content = {
                  type = "luks";
                  name = "crypted";
                  settings.allowDiscards = true;
                  passwordFile = "/tmp/secret.key";
                  content = {
                    type = "filesystem";
                    format = "ext4";
                    mountpoint = "/";
                  };
                };
              };
            };
          };
        };
      };
    };

    networking = {
      firewall.enable = false;
      hostId = "31c099d5";
      hostName = "axum";
      networkmanager = {
        enable = true;
      };
    };

    hardware = {
      raspberry-pi = {
        "4" = {
          apply-overlays-dtmerge.enable = true;
          fkms-3d = {
            enable = true;
            cma = 512;
          };
        };
        firmware = {
          enable = true;
          path = "/boot";
          uboot = {
            enable = true;
            package = pkgs.ubootRaspberryPi4_64bit;
          };
        };
        configtxt = {
          settings = {
            all = {
              dtparam = [
                "spi=on"
              ];
            };
            pi4 = {
              hdmi_enable_4kp60 = "0";
            };
          };
          deviceTreeOverlays = {
            all = {};
            pi4 = [
              {"vc4-kms-v3d" = {};}
              {"tpm-slb9670" = {};}
            ];
          };
        };
      };
      deviceTree = {
        enable = true;
      };
    };
    security.tpm2 = {
      enable = true;
      pkcs11.enable = true;
      tctiEnvironment.enable = true;
    };
    environment.systemPackages = with pkgs; [
      libraspberrypi
      raspberrypi-eeprom
    ];
    system.stateVersion = "25.11";
  };
}
