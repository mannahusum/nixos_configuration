{
  config,
  home-manager,
  pkgs,
  ...
}: {
  home.packages = with pkgs; let
    homePythonPackages = python-packages:
      with python-packages; [
        cookiecutter
        httpsig
        jedi
        pip
        pyaudio
        pylint
        pyserial
        python-slugify
        qrcode
        requests
        setuptools
        urllib3
        # used by vim
        virtualenv
      ];

    homePython310 = python310Full.withPackages homePythonPackages;
  in [
    arandr
    bashInteractive
    bat # cat clone
    cadaver
    coreutils-full
    cyrus_sasl
    dmidecode
    enscript
    file
    fzf
    gnumake
    gnupg
    homePython310
    inetutils
    lsof
    lsscsi
    man-pages
    mkpasswd
    ncurses
    nix-prefetch-git
    nodejs
    nodePackages.typescript
    pandoc
    patchelf
    pdftk
    perl
    psmisc
    pwgen
    ranger
    ripgrep
    screen
    tcpdump
    texlive.combined.scheme-full
    tldr
    units
    unzip
    usbutils
    wipe
    yarn
  ];
  programs = {
    exa.enable = true;
    bash = {
      enable = true;
      historyControl = ["ignorespace"];
      initExtra = ''
        GPG_TTY=$(tty)
      '';
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    powerline-go = {
      enable = true;
    };
  };

  programs.git = {
    enable = true;
    signing = {
      key = "christian.albertsen@kit.edu";
      signByDefault = true;
    };
    userEmail = "christian.albertsen@kit.edu";
    userName = "to6338";
  };
  programs = {
    gpg = {
      enable = true;
      mutableKeys = true;
      mutableTrust = true;
      publicKeys = [
        {
          source = builtins.fetchurl {
            url = "https://keys.openpgp.org/vks/v1/by-fingerprint/F1A1F1A33787F28359E60BFB1DBDE5EC541E1874";
            sha256 = "1r5g5bg01fvkb2flyw75hin4gvifn8za93przr6jf2bd2vx5qic5";
          };
          trust = "ultimate";
        }
      ];
    };
  };
  services.gpg-agent.enable = false;

  programs.bash.profileExtra = ''
    declare FORWARD_DIR="''${HOME}/.forwarded-sockets/"
    declare GPGHOMEDIR="''${HOME}/.gnupg/"

    forward_gpg_socket() {
      local from="''${1}"; shift
      local to="''${1}"; shift

      if [ -n "''${from}" -a -n "''${to}" ]; then
        dirname="''$(${pkgs.coreutils.out}/bin/dirname "''${from}")"
        if [ -d "''${dirname}" ]; then
          ${pkgs.coreutils.out}/bin/rm -f "''${from}" || true
          printf '%%Assuan%%\nsocket='"''${to}"'\n' >"''${from}"
        fi
      fi

    }

    find_sockets_to_forward() {
      local usage gnupgpath socket forwardedpath homepath
      while IFS=':' read -r usage gnupgpath; do
        socket="''$(${pkgs.coreutils.out}/bin/basename "''${gnupgpath}")"
        forwardedpath="''${FORWARD_DIR}''${socket}"
        homepath="''${GPGHOMEDIR}''${socket}"
        if [ -S "''${forwardedpath}" ]; then
          forward_gpg_socket "''${gnupgpath}" "''${forwardedpath}"
          forward_gpg_socket "''${homepath}" "''${forwardedpath}"
        fi
      done < <(${pkgs.gnupg.out}/bin/gpgconf -L)
    }

    find_sockets_to_forward
  '';

  home.stateVersion = "23.05";
}
