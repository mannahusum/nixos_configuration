{ config, modulesPath, lib, pkgs, ... }:
let
  cfg = config.canginx;
in {
  options.canginx = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether there should be an instance of nginx running on this server
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.nginx = {
      enable = true;
    };
    networking.firewall.allowedTCPPorts = [80 443];
  };
}
