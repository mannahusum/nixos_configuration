{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.ca.chrome;
in
  with lib; {
    imports = [
    ];

    options = {
      ca.chrome = {
        enable = mkEnableOption "Install version of google chrome";
      };
    };

    config = mkIf cfg.enable {
      home.packages = with pkgs; [
        google-chrome
      ];
      programs = {
        chromium = {
          enable = true;
        };
      };
    };
  }
