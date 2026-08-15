{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.ca.filebot;
in {
  imports = [
  ];

  options = {
    ca.filebot = {
      license = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = ''
          Path to a filebot license or null
        '';
      };
    };
  };

  config = mkIf (cfg.license != null) {
    xdg.dataFile.".local/share/filebot/data/.license".source = cfg.license;
    home.packages = with pkgs; [
      filebot
    ];
  };
}

