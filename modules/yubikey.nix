{
  config,
  lib,
  options,
  pkgs,
  ...
}: let
  cfg = config.cayubikey;
in {
  imports = [
  ];

  options.cayubikey = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether there are domains to request a certificate for
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      udev.packages = [pkgs.yubikey-personalization];
      pcscd.enable = true;
    };

    programs.gnupg.agent = {
      enableExtraSocket = true;
      enableSSHSupport = true;
      enable = true;
    };
  };
}
