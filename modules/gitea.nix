{
  config,
  lib,
  ...
}: let
  cfg = config.cagitea;
in {
  imports = [
    ./acme.nix
    ./nginx.nix
    ./postgres.nix
  ];

  options.cagitea = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether giteo should be running on this server
      '';
    };
    domain = lib.mkOption {
      type = lib.types.str;
      default = "gitea.catbertsen.de";
      description = ''
        Domain under which gitea should be reachable
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    capostgres.enable = true;
    canginx.enable = true;
    caacme.enable = true;

    # In order to access sockets of other processes give
    # nginx the right to traverse
    users.groups.gitea.members = ["nginx"];
    systemd.services.nginx.serviceConfig.ProtectHome = false;

    services = {
      nginx = {
        virtualHosts."${cfg.domain}" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://unix:/run/gitea/gitea.sock:/";
            proxyWebsockets = true;
            recommendedProxySettings = true;
            extraConfig = ''
              client_max_body_size 512M;
            '';
          };
        };
      };
      gitea = {
        enable = true;
        settings = {
          session.COOKIE_SECURE = true;
          service.DISABLE_REGISTRATION = true;
          server = {
            PROTOCOL = "http+unix";
            DOMAIN = "${cfg.domain}";
            ROOT_URL = "https://${cfg.domain}/";
            HTTP_ADDR = "/run/gitea/gitea.sock";
          };
        };
        database = {
          user = "gitea";
          type = "postgres";
        };
      };
    };
    services.postgresql = {
      ensureUsers = [
        {
          name = "gitea";
          ensureDBOwnership = true;
          ensureClauses.login = true;
        }
      ];
      ensureDatabases = [
        "gitea"
      ];
    };
    services.postgresqlBackup.databases = [
      "gitea"
    ];
  };
}
