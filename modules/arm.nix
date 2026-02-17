{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.caarm;
in {
  options.caarm = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to enable the automatic ripping-machine docker image
      '';
    };
  };

  config = lib.mkIf cfg.enable  {
    programs.zsh.enable = true;

    users.users.arm = {
      isNormalUser = true;        # Erstelle einen normalen Benutzer
      home = "/media/arm";      # Home-Verzeichnis
      group = "arm";              # Primäre Gruppe
      extraGroups = [ "wheel" ];  # Optionale zusätzliche Gruppen (z. B. für sudo-Zugriff)
      shell = pkgs.zsh;           # Benutzer-Shell (z. B. zsh oder bash)
      uid = 1001;
    };

    users.groups.arm = {
      gid = 1001;                         # Optional: spezifische GID
    };

    # Runtime
    virtualisation = {
      docker = {
        enable = true;
        autoPrune.enable = true;
        daemon.settings = {
          userland-proxy = false;
          experimental = true;
          ipv6 = true;
          fixed-cidr-v6 = "fd00::/80";
        };
      };
      oci-containers.backend = "docker";
      oci-containers.containers."arm-ripper" = {
        pull = "always";
        image = "automaticrippingmachine/automatic-ripping-machine:latest";
        #ports = [ "8080:8080" ];
        ports = [ "28982:8080" ];
        environment = {
          ARM_UID = "1000";
          ARM_GID = "1001";
          TZ = "Europe/Berlin";
        };
        volumes = [
          "/mnt:/mnt"
          "/media/arm:/home/arm"
          "/etc/arm/config:/etc/arm/config"
          "/media/audio/arm:/home/arm/Music"
          "/var/log/arm:/home/arm/logs"
          # "/media/arm/media:/home/arm/media"
        ];
        devices = [
          "/dev/sr0:/dev/sr0"
          "/dev/sr1:/dev/sr1"
          "/dev/sr2:/dev/sr2"
          "/dev/sr3:/dev/sr3"
          "/dev/sg0:/dev/sg0"
          "/dev/sg1:/dev/sg1"
          "/dev/sg2:/dev/sg2"
        ];
        privileged = true;
        autoStart = true;
      };
    };

    # Containers
    networking.firewall = {
      allowedTCPPorts = [ 28982 ];
    };
  };
}

