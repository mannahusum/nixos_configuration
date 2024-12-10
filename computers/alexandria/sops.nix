({config, ...}: {
  config.sops = {
    defaultSopsFile = ./secrets.yaml;
    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    secrets = {
      "secureboot/GUID" = {
        path = "/etc/secureboot/GUID";
      };
      "secureboot/db/public" = {
        path = "/etc/secureboot/keys/db/db.pem";
      };
      "secureboot/db/private" = {
        path = "/etc/secureboot/keys/db/db.key";
      };
      "secureboot/KEK/public" = {
        path = "/etc/secureboot/keys/KEK/KEK.pem";
      };
      "secureboot/KEK/private" = {
        path = "/etc/secureboot/keys/KEK/KEK.key";
      };
      "secureboot/PK/public" = {
        path = "/etc/secureboot/keys/PK/PK.pem";
      };
      "secureboot/PK/private" = {
        path = "/etc/secureboot/keys/PK/PK.key";
      };
    };
  };
})
