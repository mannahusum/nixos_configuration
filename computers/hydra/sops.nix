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
      "aws/key" = {};
      "aws/secret" = {};
      "aws/hosted_zone/catbertsen.de" = {};
      "xandikos/user" = {};
      "xandikos/password" = {};
      "xandikos/hashed" = {};
      "mailserver/user" = {};
      "mailserver/token" = {};
    };
    templates."route53Credentials" = {
      content = ''
        AWS_ACCESS_KEY_ID="${config.sops.placeholder."aws/key"}"
        AWS_SECRET_ACCESS_KEY="${config.sops.placeholder."aws/secret"}"
        AWS_REGION=us-east-1
        AWS_HOSTED_ZONE_ID="${config.sops.placeholder."aws/hosted_zone/catbertsen.de"}"
      '';
      owner = "acme";
    };
    templates."xandikosBasicAuth" = {
      content = ''
        ${config.sops.placeholder."xandikos/user"}:${config.sops.placeholder."xandikos/hashed"}
      '';
      owner = "nginx";
    };
  };
})
