{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.cawayland;
in {
  imports = [
    ./users.nix
  ];

  options.causermount = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Enable regular users to mount removable media on this machine
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.udisks2.enable = true;
    environment.defaultPackages = with pkgs; [ udisks bashmount usermount ];
  };
}

