{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.causermount;
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
    environment.etc."udisks2/mount_options.conf".text = ''
      [defaults]
      ntfs_drivers=ntfs,ntfs3
    '';
    environment.defaultPackages = with pkgs; [udisks bashmount usermount];
  };
}
