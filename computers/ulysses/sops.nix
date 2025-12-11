({config, ...}: {
  config.sops = {
    defaultSopsFile = ./secrets.yaml;
    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    secrets = {
      "secureboot/GUID" = {
        path = "/var/lib/sbctl/GUID";
        mode = "0644";
        owner = "root";
        group = "root";
      };
      "secureboot/db/public" = {
        path = "/var/lib/sbctl/keys/db/db.pem";
      };
      "secureboot/db/private" = {
        path = "/var/lib/sbctl/keys/db/db.key";
      };
      "secureboot/KEK/public" = {
        path = "/var/lib/sbctl/keys/KEK/KEK.pem";
      };
      "secureboot/KEK/private" = {
        path = "/var/lib/sbctl/keys/KEK/KEK.key";
      };
      "secureboot/PK/public" = {
        path = "/var/lib/sbctl/keys/PK/PK.pem";
      };
      "secureboot/PK/private" = {
        path = "/var/lib/sbctl/keys/PK/PK.key";
      };
    };
  };
})
