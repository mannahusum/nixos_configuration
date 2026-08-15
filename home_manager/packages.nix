{pkgs, lib, ...}: {
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
  in [
    bashInteractive
    bat # cat clone
    black
    coreutils-full
    cyrus_sasl
    detect-secrets
    enscript
    texliveFull
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
    pandoc
    patchelf
    pciutils
    pdftk
    perl
    pwgen
    qrcode
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
    unrar
    unzip
    usbutils
    wipe
    libxml2
    xmlstarlet
    xauth
    yarn
    yubikey-manager
  ] ++ lib.optionals (stdenv.hostPlatform.isLinux) [
    adoptopenjdk-icedtea-web
    cadaver
    dmidecode
    lsscsi
    psmisc
    tk-8_5
    zathura
  ];
}
