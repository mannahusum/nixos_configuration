{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.casaned;
in {
  imports = [
    ./users.nix
  ];

  options.casaned = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether there should be a saned running on this computer in order to make a scanner accessible to the network
      '';
    };
  };

  config = {
    hardware.sane = {
      enable = true;
      openFirewall = true;
    };
    services.saned.enable = true;
  };
}
