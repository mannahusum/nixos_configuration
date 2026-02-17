{
  config,
  lib,
  ...
}: let
  cfg = config.cabackupserver;
in {
  options.cabackupserver = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether this computer should backup itself to somewhere
      '';
    };
    username = lib.mkOption {
      type = lib.types.str;
      default = "alexandretta.local";
      description = ''
        username the client connects as
      '';
    };
    sshkey = lib.mkOption {
      type = lib.types.str;
      description = ''
        SSHKey used by the backup client
      '';
    };
  };

  config = {
    users = {
      users = {
        "${cfg.username}" = {
          group = "syncoid";
          isNormalUser = lib.mkForce true;
          # For syncoid to be able to create /var/lib/syncoid/.ssh/
          # and to use custom ssh_config or known_hosts.
          home = "/var/lib/backup/${cfg.username}";
          createHome = lib.mkForce true;
        };
      };
      groups = {
        syncoid = {};
      };
    };
    system.activationScripts."zz-${cfg.username}-authorizedKeys".text = let
      keydir = "/etc/ssh/authorized_keys.d";
      keyfile = "${keydir}/${cfg.username}";
    in ''
      mkdir -p "${keydir}";
      rm -f "${keyfile}";
      touch "${keyfile}";
      echo "${cfg.sshkey}" >>"${keyfile}"
      echo >>"${keyfile}"
      chmod +r "${keyfile}"
    '';
  };
}
