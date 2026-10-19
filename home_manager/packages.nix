{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.ca.packages;
in {
  imports = [
  ];

  options = {
    ca.packages = {
      enable = mkEnableOption "Install user packages";
      desktop = mkEnableOption "Install packages for desktop work";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; let
      homePythonPackages = python-packages:
        with python-packages; [
          pathspec
          pyaudio
          pyserial
          setuptools
          torch
          urllib3
          uv
        ];

      homePython3 = python314.withPackages homePythonPackages;
    in
      [
        bashInteractive
        bat # cat clone
        black
        coreutils-full
        cyrus_sasl
        detect-secrets
        enscript
        file
        fzf
        # home-manager
        homePython3
        inetutils
        ipmitool
        jq
        lsof
        man-pages
        mkpasswd
        ncdu
        ncurses
        nix-prefetch-git
        nodejs
        typescript
        patchelf
        pciutils
        perl
        pwgen
        ranger
        ripgrep
        shellcheck
        screen
        sops
        tcl
        tclreadline
        tcpdump
        tldr
        units
        unzip
        usbutils
        wipe
        libxml2
        xmlstarlet
        xauth
        yarn
        yubikey-manager
      ]
      ++ lib.optionals (stdenv.hostPlatform.isLinux) [
        bmaptool
        cadaver
        dmidecode
        lsscsi
        psmisc
      ]
      ++ lib.optionals (cfg.desktop) [
        adoptopenjdk-icedtea-web
        pandoc
        pdftk
        qrcode
        texliveFull
        tk-8_5
        zathura
      ];
  };
}
