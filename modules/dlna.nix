{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.cadlna;
in {
  imports = [
  ];

  options.cadlna = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to enable DLNA video sharing
      '';
    };
    name = lib.mkOption {
      type = lib.types.str;
      default = "Alexandretta";
      description = ''
        Friendly name of Sharing Service
      '';
    };
    nvidiaAccelerationPath = lib.mkOption {
      type = lib.types.nullOr (lib.types.pathWith {
        inStore = false;
        absolute = true;
      });
      default = null;
      example = "/dev/dri/by-path/pci-0000:01:00.0-render";
      description = ''
        path to an nvidia graphics card dri render path or null
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.jellyfin = {
      enable = true;
      openFirewall = true;
      hardwareAcceleration = lib.mkIf (cfg.nvidiaAccelerationPath != null) {
        enable = true;
        type = "nvenc";
        device = cfg.nvidiaAccelerationPath;
      };
    };
    environment.systemPackages = with pkgs; [
      ffmpeg-full
      filebot
    ];
  };
}

