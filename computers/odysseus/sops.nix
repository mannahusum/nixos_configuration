({config, ...}: {
  config = {
    sops = {
      defaultSopsFile = ./secrets.yaml;
      age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
      secrets = {
        "secureboot/GUID" = {
          owner = "root";
          group = "root";
          mode = "0644";
        };
        "secureboot/keys/db/db.pem" = {
          owner = "root";
          group = "root";
          mode = "0600";
        };
        "secureboot/keys/db/db.key" = {
          owner = "root";
          group = "root";
          mode = "0600";
        };
        "secureboot/keys/KEK/KEK.pem" = {
          owner = "root";
          group = "root";
          mode = "0600";
        };
        "secureboot/keys/KEK/KEK.key" = {
          owner = "root";
          group = "root";
          mode = "0600";
        };
        "secureboot/keys/PK/PK.pem" = {
          owner = "root";
          group = "root";
          mode = "0600";
        };
        "secureboot/keys/PK/PK.key" = {
          owner = "root";
          group = "root";
          mode = "0600";
        };
        "mailserver/user" = {};
        "mailserver/token" = {};
      };
    };
    systemd.tmpfiles.rules = [
      "L+ /var/lib/sbctl - - - - ${dirOf config.sops.secrets."secureboot/GUID".path}"
    ];
    boot.lanzaboote.pkiBundle = "${dirOf config.sops.secrets."secureboot/GUID".path}";
  };
})
