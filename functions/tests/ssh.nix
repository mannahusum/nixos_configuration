{pkgs ? import <nixpkgs> {}}: let
  inherit (pkgs) lib;
  ssh = import ../ssh.nix {inherit (pkgs) lib;};
  standard-config = {
    identitiesOnly = true;
    forwardAgent = true;
    forwardX11 = true;
  };
  vagrant_pub_key_rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key";
  vagrant_pub_key_ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN1YdxBpNlzxDqfJyw/QKow1F+wvG9hXGoqiysfJOn5Y vagrant insecure public key";
  vagrant_pub_keys = lib.strings.concatStringsSep "\n" [
    vagrant_pub_key_rsa
    vagrant_pub_key_ed25519
  ];
  vagrant_pub_rsa_key_file = pkgs.writeText "vagrant.rsa.pub" vagrant_pub_key_rsa;
  vagrant_pub_key_file = pkgs.writeTextFile {
    name = "vagrant.pub";
    text = vagrant_pub_keys;
  };
in {
  testSSHBasicSettingsEmpty = {
    expr = ssh.host-config standard-config null {};
    expected = {};
  };
  testSSHBasicSettingsNoSettings = {
    expr = ssh.host-config standard-config null {
      emptytesthost = {
        hostname = "emptytesthost";
      };
    };
    expected = {
      emptytesthost = {
        identitiesOnly = true;
        forwardAgent = true;
        forwardX11 = true;
        hostname = "emptytesthost";
      };
    };
  };
  testSSHBasicSettingsTwoHosts = {
    expr = ssh.host-config standard-config null {
      emptytesthost = {
        hostname = "emptytesthost";
      };
      othertesthost = {
        hostname = "thevoid";
      };
    };
    expected = {
      emptytesthost = {
        identitiesOnly = true;
        forwardAgent = true;
        forwardX11 = true;
        hostname = "emptytesthost";
      };
      othertesthost = {
        identitiesOnly = true;
        forwardAgent = true;
        forwardX11 = true;
        hostname = "thevoid";
      };
    };
  };
  testSSHBasicSettingsIdentitiesAsString = {
    expr = ssh.host-config standard-config " " {
      emptytesthost = {
        hostname = "emptytesthost";
      };
    };
    expected = {
      emptytesthost = {
        identitiesOnly = true;
        forwardAgent = true;
        forwardX11 = true;
        hostname = "emptytesthost";
        identityFile = " ";
      };
    };
  };
  testSSHBasicSettingsIdentitiesAsOut = {
    expr = ssh.host-config standard-config vagrant_pub_key_file.out {
      emptytesthost = {
        hostname = "emptytesthost";
      };
    };
    expected = {
      emptytesthost = {
        identitiesOnly = true;
        forwardAgent = true;
        forwardX11 = true;
        hostname = "emptytesthost";
        identityFile = vagrant_pub_key_file.out;
      };
    };
  };
  testSSHBasicSettingsIdentitiesAsArray = {
    expr = ssh.host-config standard-config vagrant_pub_key_file.out {
      emptytesthost = {
        hostname = "emptytesthost";
      };
    };
    expected = {
      emptytesthost = {
        identitiesOnly = true;
        forwardAgent = true;
        forwardX11 = true;
        hostname = "emptytesthost";
        identityFile = vagrant_pub_key_file.out;
      };
    };
  };
  testSSHOverrideForwardX11IdentityFile = {
    expr = ssh.host-config standard-config vagrant_pub_key_file.out {
      emptytesthost = {
        hostname = "emptytesthost";
        overrides = {
          forwardX11 = false;
          identityFile = vagrant_pub_rsa_key_file.out;
        };
      };
    };
    expected = {
      emptytesthost = {
        identitiesOnly = true;
        forwardAgent = true;
        forwardX11 = false;
        hostname = "emptytesthost";
        identityFile = vagrant_pub_rsa_key_file.out;
      };
    };
  };
}
