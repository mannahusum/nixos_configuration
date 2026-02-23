{
  config,
  lib,
  ...
}: let
  cfg = config.cabackupclient;
in {
  imports = [
    ./sshd.nix
  ];

  options.cabackupclient = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether this computer should backup itself to somewhere
      '';
    };
    serverAddress = lib.mkOption {
      type = lib.types.str;
      default = "alexandretta.local";
      description = ''
        Server to push the backups to
      '';
    };
    serverHostkey = lib.mkOption {
      type = lib.types.path;
      default = ../computers/alexandretta/extra-files/etc/ssh/ssh_host_ed25519_key.pub;
      description = ''
        SSH HostKey of the backup server
      '';
    };
    remoteUser = lib.mkOption {
      type = lib.types.str;
      default = "${config.networking.hostName}-backup";
      description = ''
        Username for backup on the server
      '';
    };
    remotePath = lib.mkOption {
      type = lib.types.str;
      default = "tank/backup/${config.networking.hostName}";
    };
    dataSets = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = ["tank/media"];
      description = ''
        List of zfs paths to backup
      '';
    };
  };

  config = {
    services = {
      openssh.knownHosts."${cfg.serverAddress}".publicKey = builtins.readFile cfg.serverHostkey;
      sanoid = {
        enable = true;
        templates.production = {
          yearly = 1;
          monthly = 6;
          hourly = 12;
          daily = 16;
          autosnap = true;
          autoprune = true;
          script_timeout = 0; # infinite
        };
        datasets =
          lib.lists.foldl (
            left: right:
              left
              // {
                "${right}" = {
                  use_template = ["production"];
                  recursive = true;
                  process_children_only = true;
                };
              }
          ) {}
          cfg.dataSets;
      };
      syncoid = {
        enable = true;
        sshKey = config.sops.secrets."syncoid/private".path;
        commands =
          lib.lists.foldl (
            left: right:
              left
              // {
                "${right}" = {
                  target = "${cfg.remoteUser}@${cfg.serverAddress}:${cfg.remotePath}/${right}";
                  recursive = true;
                };
              }
          ) {}
          cfg.dataSets;
      };
    };
  };
}
