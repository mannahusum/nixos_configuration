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
    systemd.tmpfiles.rules = [
      "L+ /var/lib/sbctl - - - - ${dirOf config.sops.secrets."secureboot/GUID".path}"
    ];
    boot.lanzaboote.pkiBundle = "${dirOf config.sops.secrets."secureboot/GUID".path}";
  };
})
