{pkgs ? import <nixpkgs> {}}: let
  inherit (pkgs) lib;
  inherit (lib) runTests;
  ssh = import ../ssh.nix {inherit lib;};

  standard-config = {
    identitiesOnly = true;
    forwardAgent = true;
    forwardX11 = true;
  };
  itiv-config =
    standard-config
    // {
      user = "to6338";
    };
  privateHosts = {
    "wudika" = {
      hostname = "ssl.wudika.de";
      hostkeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOIJoES+tRruLrrhH9CcDJZJ652gBaMV7KcwOXBLReCs"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDxwNYupZCFm6aaQM7G1/tSPvnni61EOdUHE91oVmsAwY4pl+s+ZdaBgD/8rFN/7/I/n5CdeoZZcGeXVw0WVfF4ZLReCqQoFO71H8nLdQmOExMco1NPnSlVC82lRbM4t00dLwVbfSzfZDZ4uBsNLJe5K5s4ZV2fuuqHPJtt/EH0kpBi98gJkjLhyP3GI6AC0/9m45at/4g0G9ZktsYcnsYjq88pnv64K/OoKVf8aeNYwUle0cKdZOVOuAUU3PqUt1gV7Yi40BW5CUJXH7zusCO5xlim96/YdXg4eu+r5Bj9NBOSjO68f6aH7J69QlDjPmGYyqS9hIeShvw8ArH+nu8z"
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBAOrA3zmMzoNbuX7H0o+7LC+YNN7q/Ise0OscQBVvEnTE63g4BrTc0DrwzShguPnxlKMPZqzPeK/GPdzJ8DNNBE="
      ];
      overrides = {
        user = "manna";
      };
    };
  };
  itivHosts = {
    "itiv-infopi1" = {
      hostname = "itiv-infopi1.itiv.kit.edu";
      hostkeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDO3XOvQEr/yztNACcygXv7VUdkY1OrfJBgEJ2nGphlcHiDJDgGSJDkklkfQOQwmVkBgcEAjTOr6YjzGmWo28DrpQP71Rh3mKJddHcrQHdQX97OfN4ClJfWEpE44X8oEXpZNKJoSZ/r9pteB+eB25B+VgZMcesxJg21+KIrvuE0q4UiPnqeZkcVVawKqbLPrDcwvosew76BV3ASJehhhjMqUkhzd35asxMJxC8FNDQzjvEvN1B68aB/oajNKWATA2mLK1PwLICsukhA1IVl958gW+GZXX3Gvpfg4aJcqXzoMspPvZzfku7IQqa4anmcGHUeG0djvOh9L7F2sL48POXT"
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBM3Kh1CoX8Q0cbbS5sifv1C9y9UNm69MHSAqz/PyMKObcOZ844dtLyTNoBcs9uVFHJYnRPMzMOk4AzWln6Nnt20="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILdkYRsbztp2zo6n30cPU2VZAto864nxccfyCimk89z9"
      ];
      overrides = {
        user = "pi";
        proxyJump = "nixos-substitute";
      };
    };
    "nixos-substitute" = {
      hostname = "nixos-substitute.itiv.kit.edu";
      hostkeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDOksupsvA7m6OJ7z0gK1Bit3tlE4drw9z0XtXOt1IaHH8zuW+Hy6RSTHLv1RA97Z8VCNF2m5erNd03PQ0eLgIF9DVrfaI4G1UzQB54dhL9GISG4VBDlPG1L+pRBckpgWCXHo94nWpdgYQA1D4LtwwSkAsjNuSlxm6O46zlS/XjiPArms0KoVMOGUUnaBBWKF3kF4F0R4E3859Kyo30Yohulii8T3Bo/gGpZyffV9iIHWZtv6Pi9+2JOh3TOsyJ5tf3GYX49yB/J4RmDqDov0yGxgiJiNnH5LYacWhfNfeHTOmNf2sGzgQanP1tGkyiMbfZefHbB/GOpqdtBcfKq9KBborQguGNQnzVlp4HnKCRu2v6ezATOLEG5SRHjHtVYklI7FFL2f+jzHnY67z4ZlYXtdwnuue2yH43UhUIOOOnXnl4l6EI46mmstid/DAAQ47PaZMb/nnGtks90EKwTeVbv9YNTAvFzK11ks1uXRUJKzHvhDw58Sc4ya7tzYUTMJChGm6RC0Dq1VIzfWpD4X+U2fvnghhZX8c0aShUOalkgONlf46S7lm1RwbMKsQcVAHmpMvyu5wfLcfkdKWcBvvJJ+HLdOpZl3De71Xxt1/tL8mShpT11Vn68ZltxU7YX30ZbKbPAPclcemxMc7KLgZzTuSwgDfUVcnSu0d/Hw/uwQ=="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIWKUNueuWanuJjxsOsbAc3JpzGTR3FuVDXSkEuymQFt"
      ];
    };
  };
  testkeys = {
    first = {
      private = ''
        -----BEGIN OPENSSH PRIVATE KEY-----
        b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
        QyNTUxOQAAACAYEc5fKup+7DJPuk2vmu1YlRQdGw3wo1cTKAqhQmfsugAAAJhf+a4zX/mu
        MwAAAAtzc2gtZWQyNTUxOQAAACAYEc5fKup+7DJPuk2vmu1YlRQdGw3wo1cTKAqhQmfsug
        AAAEDxzUZAiHH+QLSV5JgK+2Y6Esmv6wSl1aqHyk3xxzNJeBgRzl8q6n7sMk+6Ta+a7ViV
        FB0bDfCjVxMoCqFCZ+y6AAAAFGtpdFx0bzYzMzhAaXRpdi00MDE5AQ==
        -----END OPENSSH PRIVATE KEY-----
      '';
      public = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBgRzl8q6n7sMk+6Ta+a7ViVFB0bDfCjVxMoCqFCZ+y6 kit\to6338@itiv-4019";
    };
    second = {
      private = ''
        -----BEGIN OPENSSH PRIVATE KEY-----
        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
        -----END OPENSSH PRIVATE KEY-----
      '';
      public = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDYwdPtWY2cmQzJTd1ezMa4k7msuEZOXdnhM8rE3jkJ/rV/mLc05Rzny/2WZqhJbn6CeZUQuN+Nxx5Mh585B1cgrwr2HPDzGi9Ra43+6sN8m40Rkydg33kvQCTpUR++Trb+wxJshsOGiToKXo4+2YK+F0JmBUhCJSkWhc4Ez/jH76sR4CYTvatIThyO54eXQ74HGMXg2YI3D6EOVCMGDgsrqDixyoTndUcOG6oJQNIS5EyiNdmQ3tXah0v4BWiKCwBcBMzxStASfPmqatP/Bmedm8jqXdodzGWB4GMinnX8azjQ/i7ojDCCeQXS8+F9EdiPLp5OliCOTNeQiMaIU9HPewC9CtbOSnNVjVkLi6CtlxWTRR5W/jqEADnoNHCq5hR0sT8kTpxM/X9f6Y61s7JInHkfY1JAsFDqc1B27rBrgZuqh1pl/RGGjKlxIYZGC/p0hhraK+yD8OihkG1I5Fvd6HjvaZqhAb45g4XPaJH83UpftWHZTwhBnySdL9sz0uc= kit\to6338@itiv-4019";
    };
  };
  testkeyfiles =
    lib.mapAttrs (
      name: value: {
        public = builtins.toFile ".pub" value.public;
        private = builtins.toFile ".key" value.private;
      }
    )
    testkeys;
  publickeys = lib.mapAttrsToList (name: lib.attrByPath ["public"]) testkeys;
  publickeyfiles = lib.mapAttrsToList (name: lib.attrByPath ["public"]) testkeyfiles;
in {
  testSSHBasicSettingsEmpty = {
    expr = ssh.host-config standard-config {};
    expected = {};
  };
  testSSHBasicSettingsPrivate = {
    expr = ssh.host-config standard-config "blubb" privateHosts; #testkeys.first.public ];
    expected = {
      "wudika" = {
        hostname = "ssl.wudika.de";
        #identityFile = [ testkeyfiles.first.public ];
        identitiesOnly = true;
        forwardAgent = true;
        forwardX11 = true;
        user = "manna";
      };
    };
  };
  testSSHBasicSettingsItiv = {
    expr = ssh.host-config itiv-config "blubb" itivHosts; #publickeys;
    expected = {
      "nixos-substitute" = {
        hostname = "nixos-substitute.itiv.kit.edu";
        #identityFile = ;
        identitiesOnly = true;
        forwardAgent = true;
        forwardX11 = true;
        user = "to6338";
      };
      "itiv-infopi1" = {
        hostname = "itiv-infopi1.itiv.kit.edu";
        #identityFile = lib.mapAttrsToList (name: lib.attrByPath [ "public" ] ) testkeyfiles;
        identitiesOnly = true;
        forwardAgent = true;
        forwardX11 = true;
        user = "pi";
        proxyJump = "nixos-substitute";
      };
    };
  };
}
