{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.cauefi;
in {
  imports = [
  ];

  options.cauefi = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether there are domains to request a certificate for
      '';
    };
    # domains = lib.mkOption {
    #   type = lib.types.listOf lib.types.str;
    #   default = [];
    #   description = ''
    #     Domains for which to request certificates
    #   '';
    # };
  };

  config = lib.mkIf cfg.enable {
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

    environment.systemPackages = with pkgs; [
      sbctl
      tpm2-tools
    ];
  };
}
