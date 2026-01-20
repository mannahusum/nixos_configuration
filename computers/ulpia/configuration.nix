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
    disko.devices = let
      boot = "/dev/disk/by-id/usb-Swissbit_USB_Flash_Drive_601924969200008C-0:0";
      nvme = ["/dev/disk/by-id/nvme-Lexar_SSD_NM620_2TB_QBS830R004175P1125" "/dev/disk/by-id/nvme-Lexar_SSD_NM620_2TB_QBS830R000758P1125"];
      rotating = ["/dev/disk/by-id/ata-ST14000NM001G-2KJ103_ZL28WN0G" "/dev/disk/by-id/ata-ST14000NM001G-2KJ103_ZL2E4EBQ" "/dev/disk/by-id/ata-ST14000NM001G-2KJ103_ZL2E4HML" "/dev/disk/by-id/ata-ST14000NM001G-2KJ103_ZL2EFR06"];
      swapsize = "172G";
    in {
      disk = let
        bootlayout = device: {
          inherit device;
          type = "disk";
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                size = "100%";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                };
              };
            };
          };
        };
        nvmelayout = device: efimountpoint: counter: {
          inherit device;
          type = "disk";
          content = {
            type = "gpt";
            partitions = lib.mkMerge [
              (lib.mkIf (efimountpoint != null) {
                ESP = {
                  size = "1G";
                  type = "EF00";
                  content = {
                    type = "filesystem";
                    format = "vfat";
                    mountpoint = efimountpoint;
                  };
                };
              })
              {
                swap = {
                  size = swapsize;
                  content = {
                    type = "mdraid";
                    name = "swap";
                  };
                };
                l2arc = {
                  size = "1024G";
                  content = {
                    type = "luks";
                    name = "l2arc${builtins.toString counter}";
                    initrdUnlock = true;
                    passwordFile = "/tmp/secret.key";
                    settings.allowDiscards = true;
                  };
                };
                rpool = {
                  size = "100%";
                  content = {
                    type = "luks";
                    name = "rpool${builtins.toString counter}";
                    initrdUnlock = true;
                    passwordFile = "/tmp/secret.key";
                    settings.allowDiscards = true;
                    content = {
                      type = "zfs";
                      pool = "rpool";
                    };
                  };
                };
              }
            ];
          };
        };
        rotatinglayout = device: counter: {
          inherit device;
          type = "disk";
          content = {
            type = "gpt";
            partitions = {
              tank = {
                size = "100%";
                content = {
                  type = "luks";
                  name = "tank${builtins.toString counter}";
                  passwordFile = "/tmp/secret.key";
                  initrdUnlock = true;
                  settings.allowDiscards = true;
                  content = {
                    type = "zfs";
                    pool = "tank";
                  };
                };
              };
            };
          };
        };
      in
        lib.mkMerge [
          (lib.mkIf (boot != null) {boot = bootlayout boot;})
          (lib.lists.foldl' (a: b: a // b) {} (lib.lists.imap0 (i: v: {"nvme${toString i}" = nvmelayout "${v}" null i;}) nvme))
          (lib.lists.foldl' (a: b: a // b) {} (lib.lists.imap0 (i: v: {"rotating${toString i}" = rotatinglayout "${v}" i;}) rotating))
        ];
      mdadm = {
        swap = {
          type = "mdadm";
          level = 1;
          metadata = "1.0";
          content = {
            type = "swap";
          };
        };
      };
      zpool = {
        rpool = {
          type = "zpool";
          mode = "mirror";
          options = {
            ashift = "13";
          };
          rootFsOptions = {
            compression = "lz4";
            "com.sun:auto-snapshot" = "false";
            mountpoint = "none";
            xattr = "sa";
            acltype = "posixacl";
            atime = "off";
            relatime = "off";
            dedup = "on";
          };
          postCreateHook = "zfs snapshot rpool@blank";

          datasets = {
            root = {
              type = "zfs_fs";
              options.mountpoint = "none";
            };
            "root/nixos" = {
              type = "zfs_fs";
              options = {
                mountpoint = "legacy";
                "com.sun:auto-snapshot" = "false";
              };
              mountpoint = "/";
            };
            home = {
              type = "zfs_fs";
              mountpoint = "/home";
            };
            reserved = {
              type = "zfs_fs";
              options = {
                refreservation = "1G";
                mountpoint = "none";
              };
            };
          };
        };
        tank = let
          smbShare = mountpoint: {
            inherit mountpoint;
            type = "zfs_fs";
            options = {
              mountpoint = "legacy";
              "com.sun:auto-snapshot" = "false";
            };
          };
        in {
          type = "zpool";
          mode = "raidz1";
          options = {
            ashift = "13";
          };
          rootFsOptions = {
            compression = "lz4";
            "com.sun:auto-snapshot" = "false";
            mountpoint = "none";
            xattr = "sa";
            acltype = "posixacl";
            atime = "off";
            relatime = "off";
            dedup = "on";
          };
          postCreateHook = "zfs snapshot tank@blank";

          datasets = {
            media = {
              type = "zfs_fs";
              options.mountpoint = "none";
            };
            vms = {
              type = "zfs_fs";
              options.mountpoint = "none";
            };
            "media/audio" = smbShare "/media/audio";
            "media/games" = smbShare "/media/games";
            "media/games/wii" = smbShare "/media/games/wii";
            "media/images" = smbShare "/media/images";
            "media/onqm" = smbShare "/media/onqm";
            "media/software" = smbShare "/media/software";
            "media/ultrastar" = smbShare "/media/ultrastar";
            "media/video" = smbShare "/media/video";
            "backup" = {
              type = "zfs_fs";
              options = {
                mountpoint = "none";
                "com.sun:auto-snapshot" = "false";
              };
            };

            reserved = {
              type = "zfs_fs";
              options = {
                refreservation = "1G";
                mountpoint = "none";
              };
            };
          };
        };
      };
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
    services.minidlna = {
      enable = true;
      settings = {
        notify_interval = 60;
        friendly_name = "Ulpia";
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
    systemd.network = {
      enable = true;
      links = {
        "20-persistent-net-name-eth0" = {
          matchConfig.PermanentMACAddress = "00:1e:67:54:16:8a";

          linkConfig.Name = "eth0";
        };
        "20-persistent-net-name-eth1" = {
          matchConfig.PermanentMACAddress = "00:1e:67:54:16:8b";
          linkConfig.Name = "eth1";
        };
        "25-br0" = {
          matchConfig.OriginalName = "br0";
          linkConfig.MACAddressPolicy = "none";
        };
      };
      netdevs = {
        "10-br0" = {
          netdevConfig = {
            Kind = "bridge";
            Name = "br0";
            MACAddress = "none";
          };
        };
      };
      networks = {
        "30-eth0" = {
          matchConfig.Name = "eth0";
          networkConfig.Bridge = "br0";
          linkConfig.RequiredForOnline = "enslaved";
        };
        "30-eth1" = {
          matchConfig.Name = "eth1";
          networkConfig.DHCP = "yes";
          linkConfig.RequiredForOnline = "no";
        };
        "40-br0" = {
          matchConfig.Name = "br0";
          bridgeConfig = {};
          networkConfig = {
            DHCP = "ipv4";
            IPv6AcceptRA = true;
          };
          linkConfig.RequiredForOnline = "routable";
        };
      };
    };

    # containers.rex = {
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
      hostId = "d22d38ba";
      hostName = "ulpia";
      tempAddresses = "disabled";
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
        efitools
        file
        git
        git-crypt
        mkvpkgs.makemkv
        neovim
        ripgrep
        sbctl
        sbsigntool
        tpm2-tss
        xterm # for resize command
      ];

    system.stateVersion = "23.11";
    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
        ncurses5
        gccNGPackages_15.libstdcxx
        openipmi
      ];
    };
  };
})
