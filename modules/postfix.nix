{
  config,
  lib,
  ...
}: let
  cfg = config.capostfix;
in {
  imports = [
    ./acme.nix
    ./nginx.nix
    ./postgres.nix
  ];

  options.capostfix = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether giteo should be running on this server
      '';
    };
    connection = lib.mkOption {
      type = lib.types.str;
      default = "smtp.protonmail.ch:587";
      description = ''
        Host and port to connect to in order to deliver the emaul
      '';
    };
    mydomain = lib.mkOption {
      type = lib.types.str;
      default = "catbertsen.de";
      description = ''
        The domain to consider "local" for this Host
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    sops = {
      templates."mailserver_from_rewrite" = {
        content = ''
          /^.*$/ ${config.sops.placeholder."mailserver/user"}
        '';
        owner = "postfix";
      };
      templates."mailserver_login" = {
        content = ''
          ${cfg.connection} ${config.sops.placeholder."mailserver/user"}:${config.sops.placeholder."mailserver/token"}
        '';
        owner = "postfix";
      };
    };
    services.postfix = {
      enable = true;
      settings.main = {
        myorigin = "${cfg.mydomain}";
        mydomain = "${cfg.mydomain}";
        mydestination = null;
        inet_interfaces = "loopback-only";
        local_recipient_maps = null;
        local_transport = "error:local mail delivery is disabled";
        myhostname = "${config.networking.hostName}.${cfg.mydomain}";
        relayhost = ["${cfg.connection}"];
        smtp_sasl_auth_enable = true;
        smtp_generic_maps = "regexp:${config.sops.templates.mailserver_from_rewrite.path}";
        smtp_sasl_password_maps = "texthash:${config.sops.templates.mailserver_login.path}";
        smtp_sasl_security_options = "noanonymous";
        smtp_tls_security_level = "encrypt";
        local_header_rewrite_clients = "static:all";
        append_dot_mydomain = true;
        smtputf8_enable = false;
      };
    };
  };
}
