{pkgs ? import <nixpkgs> {}}: let
  inherit (pkgs) lib;
  ssh = import ../ssh.nix {inherit (pkgs) lib;};
  standard-config = {
    identitiesOnly = true;
    forwardAgent = true;
    forwardX11 = true;
  };
  vagrant_sec_key_rsa = ''
    -----BEGIN RSA PRIVATE KEY-----
    MIIEogIBAAKCAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzI
    w+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoP
    kcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2
    hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NO
    Td0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcW
    yLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQIBIwKCAQEA4iqWPJXtzZA68mKd
    ELs4jJsdyky+ewdZeNds5tjcnHU5zUYE25K+ffJED9qUWICcLZDc81TGWjHyAqD1
    Bw7XpgUwFgeUJwUlzQurAv+/ySnxiwuaGJfhFM1CaQHzfXphgVml+fZUvnJUTvzf
    TK2Lg6EdbUE9TarUlBf/xPfuEhMSlIE5keb/Zz3/LUlRg8yDqz5w+QWVJ4utnKnK
    iqwZN0mwpwU7YSyJhlT4YV1F3n4YjLswM5wJs2oqm0jssQu/BT0tyEXNDYBLEF4A
    sClaWuSJ2kjq7KhrrYXzagqhnSei9ODYFShJu8UWVec3Ihb5ZXlzO6vdNQ1J9Xsf
    4m+2ywKBgQD6qFxx/Rv9CNN96l/4rb14HKirC2o/orApiHmHDsURs5rUKDx0f9iP
    cXN7S1uePXuJRK/5hsubaOCx3Owd2u9gD6Oq0CsMkE4CUSiJcYrMANtx54cGH7Rk
    EjFZxK8xAv1ldELEyxrFqkbE4BKd8QOt414qjvTGyAK+OLD3M2QdCQKBgQDtx8pN
    CAxR7yhHbIWT1AH66+XWN8bXq7l3RO/ukeaci98JfkbkxURZhtxV/HHuvUhnPLdX
    3TwygPBYZFNo4pzVEhzWoTtnEtrFueKxyc3+LjZpuo+mBlQ6ORtfgkr9gBVphXZG
    YEzkCD3lVdl8L4cw9BVpKrJCs1c5taGjDgdInQKBgHm/fVvv96bJxc9x1tffXAcj
    3OVdUN0UgXNCSaf/3A/phbeBQe9xS+3mpc4r6qvx+iy69mNBeNZ0xOitIjpjBo2+
    dBEjSBwLk5q5tJqHmy/jKMJL4n9ROlx93XS+njxgibTvU6Fp9w+NOFD/HvxB3Tcz
    6+jJF85D5BNAG3DBMKBjAoGBAOAxZvgsKN+JuENXsST7F89Tck2iTcQIT8g5rwWC
    P9Vt74yboe2kDT531w8+egz7nAmRBKNM751U/95P9t88EDacDI/Z2OwnuFQHCPDF
    llYOUI+SpLJ6/vURRbHSnnn8a/XG+nzedGH5JGqEJNQsz+xT2axM0/W/CRknmGaJ
    kda/AoGANWrLCz708y7VYgAtW2Uf1DPOIYMdvo6fxIB5i9ZfISgcJ/bbCUkFrhoH
    +vq/5CIWxCPp0f85R4qxxQ5ihxJ0YDQT9Jpx4TMss4PSavPaBH3RXow5Ohe+bYoQ
    NE5OgEXk2wVfZczCZpigBKbKZHNYcelXtTt/nP3rsCuGcM4h53s=
    -----END RSA PRIVATE KEY-----
  '';
  vagrant_sec_key_ed25519 = ''
    -----BEGIN OPENSSH PRIVATE KEY-----
    b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
    QyNTUxOQAAACDdWHcQaTZc8Q6nycsP0CqMNRfsLxvYVxqKosrHyTp+WAAAAJj2TBMT9kwT
    EwAAAAtzc2gtZWQyNTUxOQAAACDdWHcQaTZc8Q6nycsP0CqMNRfsLxvYVxqKosrHyTp+WA
    AAAEAveRHRHSCjIxbNKHDRzezD0U3R3UEEmS7R33fzvPQAD91YdxBpNlzxDqfJyw/QKow1
    F+wvG9hXGoqiysfJOn5YAAAAEHNwb3hAdmFncmFudC1kZXYBAgMEBQ==
    -----END OPENSSH PRIVATE KEY-----
  '';
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
