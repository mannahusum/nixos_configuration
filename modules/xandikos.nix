{ config, lib, options, ... }:
let
  cfg = config.caxandikos;
in {
  imports = [
    ./nginx.nix
    ./acme.nix
  ];

  options.caxandikos = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether there should be an instance of xandikos running on this server
      '';
    };
    domain = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = ''
        Domain name under which xandikos should be hosted
      '';
    };
    passwordfile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Path to a http basic auth file
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    canginx.enable = true;
    services.nginx = {
      virtualHosts."${cfg.domain}" = {
        enableACME = true;
        forceSSL = true;
        root = "/var/www/calendartest";
        locations."/.well-known/caldav".return = "307 $scheme://$host/user/calendars";
        locations."/.well-known/contacts".return = "307 $scheme://$host/user/contacts";
        basicAuthFile = cfg.passwordfile;
      };
    };
    caacme.domains = [ "${cfg.domain}" ];
    services.xandikos = {
      enable = true;
      port = 8088;
      extraOptions = ["--defaults"];
      nginx = {
        enable = true;
        hostName = "${cfg.domain}";
      };
    };
  };
}

