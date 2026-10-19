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
        # packageOverrides = super: {
        #   ubootRaspberryPi4_64bit = super.ubootRaspberryPi4_64bit.overrideAttrs (oldAttrs: {
        #     # Append custom config fragments directly to the compilation process
        #     src = super.fetchFromGitHub {
        #       owner = "aidangarske";
        #       repo = "u-boot";
        #       rev = "56099dc3211301baf7b76293fd8a39c5f2edb1f5";
        #       hash = "sha256-xHi8apxKMrhxdEFH8kVuIgVGkKseGfVqn8UOBkqePSQ=";
        #       fetchSubmodules = true;
        #     };
        #     # preConfigure = (oldAttrs.preConfigure or "") + ''
        #     #   cat <<EOF >> configs/rpi_4_defconfig
        #     #   CONFIG_TPM=y
        #     #   CONFIG_TPM_V2=y
        #     #   CONFIG_CMD_TPM=y
        #     #   CONFIG_BCM2835_SPI=y
        #     #   CONFIG_TPM2_TIS_SPI=y
        #     #   EOF
        #     # '';
        #   });
        # };
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
        supportedFilesystems = ["zfs"];
        systemd = {
          enable = true;
          extraBin = {
            cryptsetup = "${pkgs.cryptsetup}/bin/cryptsetup";
          };
          emergencyAccess = true;
          # services = {
          # #   plymouth-start = {
          # #     after = [ "systemd-modules-load.service" ];
          # #     requires = [ "systemd-modules-load.service" ];
          # #   };
          #   "systemd-cryptsetup@crypted" = {
          #     # Tells the unit to bypass plymouth's graphical agent for this specific prompt
          #     environment = { SYSTEMD_ASK_PASSWORD_AGENT_FILTER = "systemd-tty-ask-password-agent"; };
          #   };
          # };
        };
      };
      kernelParams = [
        "8250.nr_uarts=1"
        # "console=tty1"
        # "console=ttyS0,115200n8"
        "quiet"
        # "splash"
        "vt.global_cursor_default=0"
        # "rd.systemd.show_status=auto"
        # "plymouth.ignore-serial-consoles"
        # "plymouth.use-simpledrm=0"
        # "video=efifb:off"          # Disable legacy EFI framebuffers that conflict on ARM
        # "initcall_debug=0"
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

        # "cec"
        # "drm"
        # "drm_display_helper"
        # "drm_dma_player"
        # "drm_exec"
        # "drm_kms_helper"
        # "gpu-sched"
        # "snd_pcm"
        # "snd_soc_core"
        # "spi_bcm2835"
        # "tpm_tis_spi"
        # "v3d"
        # "vc4"
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

    # sdImage = {
    #   # populateFirmwareCommands = let
    #   #   configTxt = pkgs.writeText "config.txt" ''
    #   #     dtparam=audio=off
    #   #     camera_auto_detect=0
    #   #     display_auto_detect=1
    #   #     auto_initramfs=1
    #   #     dtoverlay=vc4-fkms-v3d-pi4
    #   #     max_framebuffers=2
    #   #     disable_fw_kms_setup=1
    #   #     arm_64bit=1
    #   #     disable_overscan=1
    #   #     arm_boost=1
    #   #     enable_uart=1
    #   #     kernel=u-boot.bin
    #   #   '';
    #   # in ''
    #   #   mkdir -p $NIX_BUILD_TOP/firmware/overlays/
    #   #   (cd ${pkgs.raspberrypifw}/share/raspberrypi/boot && cp bcm2711-rpi-4-b.dtb fixup4.dat start4.elf $NIX_BUILD_TOP/firmware/)
    #   #   cp ${pkgs.ubootRaspberryPi4_64bit}/u-boot.bin firmware/u-boot.bin
    #   #   cp ${configTxt} firmware/config.txt
    #   # '';
    #   populateRootCommands = ''
    #     mkdir -p ./files/boot
    #     ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./files/boot
    #   '';
    # };
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
