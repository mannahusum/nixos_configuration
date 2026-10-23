{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.caembedded;
in {
  imports = [
  ];

  options.caembedded = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether there are domains to request a certificate for
      '';
    };
    sshKey = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "/etc/ssh/ssh_host_ed25519_key";
      description = ''
        Path of the ssh key to use for connecting to build machines
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment = {
      systemPackages = [
        pkgs.nrf-command-line-tools
        pkgs.segger-jlink
      ];
    };
    services.udev.packages = [
      pkgs.segger-jlink
      pkgs.nrf-udev
      (pkgs.writeTextFile {
        name = "bmaptool-optimizations-rules";
        text =
          (builtins.foldl' (acc: new: acc + "\n" + new) ''
              SUBSYSTEM!="block", GOTO="bmaptool_optimizations_end"
              ACTION!="add|change", GOTO="bmaptool_optimizations_end"
            '' (map (device: ''
                #${device.name}
                ACTION=="add", SUBSYSTEMS=="usb", ATTRS{idVendor}=="${device.vendorId}", ATTRS{idProduct}=="${device.productId}", TAG+="uaccess"
                SUBSYSTEMS=="usb", ENV{DEVTYPE}!="partition", ATTRS{idVendor}=="${device.vendorId}", ATTRS{idProduct}=="${device.productId}", ATTR{bdi/min_ratio}="0", ATTR{bdi/max_ratio}="1", ATTR{queue/scheduler}="none"
              '') [
                {
                  name = "UGreen Card Reader";
                  vendorId = "05e3";
                  productId = "0749";
                }
                {
                  name = "SanDisk Corp Ultra Flair";
                  vendorId = "0781";
                  productId = "5591";
                }
                {
                  name = "Genesys Logic, Inc. USB Storage";
                  vendorId = "05e3";
                  productId = "0764";
                }
                {
                  name = "MicroSoft Corp Surface Pro SD Card Reader";
                  vendorId = "045e";
                  productId = "0306";
                }
              ]))
          + ''
            LABEL="bmaptool_optimizations_end"
          '';
        destination = "/etc/udev/rules.d/60-bmaptool-optimizations.rules";
      })
    ];

    programs.ssh =  lib.optionalAttrs (! isNull cfg.sshKey) {
      extraConfig = let
        builderConfig = pkgs.writeTextFile {
          name = "10-mini-builder.conf";
          text = ''
            Host mini-builder
              hostname mini.local
              identityFile ${cfg.sshKey}
              user christianalbertsen

            Host mini-linux
              proxyJump mini-builder
              User builder
              hostname localhost
              Port 31022
              identityFile ${cfg.sshKey}
          '';
          destination = "/10-mini-builder.conf";
        };
      in ''
        Include ${builderConfig.out}/10-mini-builder.conf
      '';
    };
    nix = {
      settings.extra-platforms = [ "armv7l-linux" ];
    } // lib.optionalAttrs (! isNull cfg.sshKey) {
      buildMachines = [
        {
          hostName = "mini-builder";
          maxJobs = 9;
          protocol = "ssh";
          sshKey = cfg.sshKey;
          sshUser = "christianalbertsen";
          supportedFeatures = ["nixos-test" "apple-virt"];
          systems = ["aarch64-darwin"];
        }
        {
          hostName = "mini-linux";
          maxJobs = 9;
          protocol = "ssh-ng";
          sshKey = cfg.sshKey;
          sshUser = "builder";
          supportedFeatures = ["nixos-test" "benchmark" "big-parallel" "kvm" "gccarch-armv8-a"];
          systems = ["aarch64-linux"];
        }
      ];
      distributedBuilds = true;
    };
    boot.binfmt.emulatedSystems = [ "armv7l-linux" ];
  };
}
