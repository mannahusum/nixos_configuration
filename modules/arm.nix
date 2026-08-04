{
  config,
  lib,
  automatic-ripping-machine,
  ...
}: let
  cfg = config.caarm;
  baseFolder = "/media/arm/media";
in {
  imports = [
    automatic-ripping-machine.nixosModules.automatic-ripping-machine
  ];

  options.caarm = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to enable the automatic ripping-machine docker image
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    boot.kernelModules = [ "sg" ];
    programs.zsh.enable = true;


    fileSystems = builtins.listToAttrs (lib.lists.forEach (lib.lists.range 0 10) ( count: {
      name = "/mnt/dev/sr${builtins.toString count}";
      value = {
          device = "/dev/sr${builtins.toString count}";
          fsType = "udf,iso9660";
          options = [ "defaults" "utf8" "noauto" "ro" "user" "X-mount.mkdir" ];
        };
      }
    ));
    users.users.arm = {
      home = "/media/arm"; # Home-Verzeichnis
      uid = 1000;
      homeMode = "755";
      extraGroups = ["cdrom" "video"];
    };

    services.automatic-ripping-machine = {
      enable = true;
      enableTranscoding = true;
      appriseSettings = {
        NTFY_TOPIC = "ootu1ipiexodohphu6zoo7Aedeifooseayozoa3the4thar1zoh1vahKimohH8ee";
      };
      settings = {
        ALLOW_DUPLICATES = true;
        ARM_CHECK_UDF = false;
        ARM_NAME =  "Alexandretta";
        AUTO_EJECT = true;
        COMPLETED_PATH = "${baseFolder}/completed/";
        DATE_FORMAT = "%Y-%m-%d %H:%M:%S";
        DELRAWFILES = true;
        DEST_EXT = "mkv";
        DISABLE_LOGIN = true;
        EMBY_REFRESH = false;
        EXTRAS_SUB = "extras";
        GET_AUDIO_TITLE = "musicbrainz";
        GET_VIDEO_TITLE = true;
        LOGLEVEL = "DEBUG";
        MAINFEATURE = false;
        MANUAL_WAIT_TIME = 60;
        MANUAL_WAIT = true;
        MAX_CONCURRENT_MAKEMKVINFO = 1;
        MAX_CONCURRENT_TRANSCODES = 3;
        MAXLENGTH = 99999;
        # Media will be put into movies/ and shows/ subdirectories
        METADATA_PROVIDER = "omdb";
        MINLENGTH = 120;
        NOTIFY_JOBID = false;
        NOTIFY_RIP = true;
        NOTIFY_TRANSCODE = true;
        PREVENT_99 = true;
        RAW_PATH = "${baseFolder}/raw/";
        RIPMETHOD = "mkv";
        RIP_POSTER = true;
        # TODO: remove when config is final
        TRANSCODE_PATH = "${baseFolder}/transcode/";
        UMASK = "0o002";
        VIDEOTYPE = "auto";
        # WEBSERVER_IP = "127.0.0.1";
        WEBSERVER_PORT = 28982;
      };
    };

    systemd.services = {
      "arm@" = {
        serviceConfig = {
          DeviceAllow = [
            "/dev/%I rwm"
          ];
          ReadWritePaths = [
            "/media/arm"
            "/mnt/dev/%I"
            config.security.wrapperDir
            (dirOf config.sops.secrets."ripping/makemkv.key".path)
          ];
        };
        environment = {
          ARM_MAKEMKV_PERMA_KEY_FILE = config.sops.secrets."ripping/makemkv.key".path;
        };
      };
      armui = {
        serviceConfig.ReadWritePaths = [
          config.security.wrapperDir
          (dirOf config.sops.secrets."ripping/omdbapi.key".path)
        ];
        environment = {
          ARM_OMDB_API_KEY_FILE = config.sops.secrets."ripping/omdbapi.key".path;
        };
      };
    };

    # Containers
    networking.firewall = {
      allowedTCPPorts = [28982];
    };
  };
}
