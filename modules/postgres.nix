{
  config,
  lib,
  ...
}: let
  cfg = config.capostgres;
in {
  imports = [
  ];

  options.capostgres = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether there should be an instance of postgres running on this server
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.postgresql = {
      enable = true;
      settings = {
        password_encryption = "scram-sha-256";
      };
    };
    services.postgresqlBackup = {
      enable = true;
      compression = "zstd";
    };
  };
}
