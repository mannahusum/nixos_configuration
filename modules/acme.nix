{
  config,
  lib,
  ...
}: let
  cfg = config.caacme;
in {
  imports = [
  ];

  options.caacme = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether there are domains to request a certificate for
      '';
    };
    domains = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = ''
        Domains for which to request certificates
      '';
    };

    credentialsfile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Path to environmentfile with credentials
      '';
    };

    email = lib.mkOption {
      type = lib.types.str;
      default = "christian@wudika.de";
      description = ''
        Email for ACME notifications
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    security.acme = {
      acceptTerms = true;
      defaults.email = "${cfg.email}";
      certs = builtins.listToAttrs (map (domain: {
          name = "${domain}";
          value = {
            dnsProvider = "route53";
            environmentFile = "${cfg.credentialsfile}";
            webroot = null;
          };
        })
        cfg.domains);
    };
  };
}
