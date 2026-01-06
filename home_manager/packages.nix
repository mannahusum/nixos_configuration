{pkgs, ...}: {
  home = let
    homePythonPackages = python-packages:
      with python-packages; [
        pathspec
        pyaudio
        pyserial
        setuptools
        urllib3
        uv
      ];

    homePython3 = pkgs.python314.withPackages homePythonPackages;
  in {
    packages = with pkgs; [
      adoptopenjdk-icedtea-web
      bashInteractive
      bat # cat clone
      cadaver
      coreutils-full
      cyrus_sasl
      detect-secrets
      dmidecode
      enscript
      texliveFull
      file
      fzf
      home-manager
      homePython3
      inetutils
      jq
      lsof
      lsscsi
      man-pages
      mkpasswd
      ncdu
      nix-prefetch-git
      pandoc
      patchelf
      pciutils
      pdftk
      psmisc
      pwgen
      qrcode
      ranger
      ripgrep
      shellcheck
      screen
      sops
      tcpdump

      tldr
      units
      unzip
      usbutils
      wipe
      xorg.xauth
      yarn
      yubikey-manager
    ];
  };
}
