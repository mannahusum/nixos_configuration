{pkgs, ...}: {
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
    adoptopenjdk-icedtea-web
    bashInteractive
    bat # cat clone
    black
    cadaver
    coreutils-full
    cyrus_sasl
    detect-secrets
    disktype
    dmidecode
    enscript
    texliveFull
    file
    fzf
    home-manager
    homePython3
    inetutils
    ipmitool
    jq
    lsof
    lsscsi
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
    psmisc
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
    tk-8_5
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
    zathura
  ];
}
