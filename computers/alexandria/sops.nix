({config, ...}: {
  config.sops = {
    defaultSopsFile = ./secrets.yaml;
    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    secrets = {
      "syncoid/public" = {
        owner = config.services.syncoid.user;
        mode = "0444";
      };
      "syncoid/private" = {
        owner = config.services.syncoid.user;
        mode = "0400";
      };
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
      "aws/key" = {};
      "aws/secret" = {};
      "aws/hosted_zone/catbertsen.de" = {};
      "aws/hosted_zone/windows.catbertsen.de" = {};
    };
    templates = {
      "route53CatbertsenCredentials" = {
        content = ''
          AWS_ACCESS_KEY_ID="${config.sops.placeholder."aws/key"}"
          AWS_SECRET_ACCESS_KEY="${config.sops.placeholder."aws/secret"}"
          AWS_REGION=us-east-1
          AWS_HOSTED_ZONE_ID="${config.sops.placeholder."aws/hosted_zone/catbertsen.de"}"
        '';
      };
      "route53WindowsCatbertsenCredentials" = {
        content = ''
          AWS_ACCESS_KEY_ID="${config.sops.placeholder."aws/key"}"
          AWS_SECRET_ACCESS_KEY="${config.sops.placeholder."aws/secret"}"
          AWS_REGION=us-east-1
          AWS_HOSTED_ZONE_ID="${config.sops.placeholder."aws/hosted_zone/windows.catbertsen.de"}"
        '';
      };
    };
  };
})
