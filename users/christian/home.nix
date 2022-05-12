{ pkgs, config, lib, nixpkgs, ... }:
with lib;

let
  emojiCompose = pkgs.fetchurl {
    url = "https://gist.github.com/m93a/9b2056cb867f08a3fddce0004200841a/raw/e910e19fdbaf8d4e8553f052472f880a561f7f46/.XCompose";
    sha256 = "0wpcbga7aqb92p5qnvfwrybvwik3mnq1g7yca4g8hf04aycdl49g";
  };
in {

  # inherit nixpkgs;

  home.keyboard = null;

  imports = [
    ./alacritty.nix
    ./awesome.nix
    ./calibre.nix
    ./email.nix
    ./fontconfig.nix
    ./git.nix
    ./google-chrome.nix
    ./mnemosyne.nix
    ./mplayer.nix
    ./music.nix
    ./office.nix
    ./passwordsafe.nix
    ./pulseaudio.nix
    ./qemu.nix
    ./ssh.nix
    ./taskwarrior.nix
    ./todoist.nix
    ./vim.nix
    ./xscreensaver.nix
    ./zathura.nix
  ];

  nixpkgs.overlays = [
    (self: super: {
        uqm = super.uqm.overrideAttrs (
          oldAttrs: {
            buildInputs = oldAttrs.buildInputs ++ [ pkgs.libpng ];
          }
        );
        pythonPackages = super.python38Packages;
      }
    )
  ];

  home.packages = with pkgs; let

    writeShellScriptBinAndSymlink = name: text: symlinkJoin {
      name = name;
      paths = [
        (writeShellScriptBin name text)
      ];
    };

    myrpiimager = stdenv.mkDerivation rec {
      pname = "rpi-imager";
      version = "1.7.1";

      src = fetchFromGitHub {
        owner = "raspberrypi";
        repo = pname;
        rev = "v${version}";
        sha256 = "sha256-Yt+RWox+0VOw8SH7Ry/o4NHOg3IGcebVeE9OWGP17do=";
      };

      nativeBuildInputs = [ cmake util-linux libsForQt5.qt5.wrapQtAppsHook ];

      buildInputs = with libsForQt5.qt5; [
        curl
        libarchive
        qtbase
        qtdeclarative
        qtsvg
        qttools
        qtquickcontrols2
        qtgraphicaleffects
      ];

      /* By default, the builder checks for JSON support in lsblk by running "lsblk --json",
        but that throws an error, as /sys/dev doesn't exist in the sandbox.
        This patch removes the check. */
      patches = [ ./lsblkCheckFix.patch ];

      meta = with lib; {
        description = "Raspberry Pi Imaging Utility";
        homepage = "https://www.raspberrypi.org/software/";
        downloadPage = "https://github.com/raspberrypi/rpi-imager/";
        license = licenses.asl20;
        maintainers = with maintainers; [ ymarkus ];
        platforms = platforms.all;
        # does not build on darwin
        broken = stdenv.isDarwin;
      };
    };

    qrcode = python38.pkgs.buildPythonApplication rec {
      pname = "qrcode";
      version = "6.1";

      src = python38.pkgs.fetchPypi {
        inherit pname version;
        sha256= "0sa3n298b9jpz6zn0birnjii3mg9sihjq28n9nzjlzv09y2m6ljh";
      };

      checkInputs = with python38Packages; [
        pytest
        pytestcov
      ];

      propagatedBuildInputs = with python38Packages; [
        six
        setuptools
        pymaging
        pymaging_png
        pillow
      ];
    };

    dpt-rp1 = python38.pkgs.buildPythonApplication rec {
      pname = "dpt-rp1-py";
      version = "0.1.16";

      src = python38.pkgs.fetchPypi {
        inherit pname version;
        sha256 = "sha256-k8qyiVU8lUfmdtVqRmZM5N9kSgmudxkOc6E+hYhIq8M=";
      };

      # checkInputs = [ python38Packages.pytest ];

      doCheck = false;

      propagatedBuildInputs = with python38Packages; [
        anytree
        dconf
        fusepy
        httpsig
        pbkdf2
        pyserial
        pyyaml
        requests
        setuptools
        tqdm
        urllib3
        zeroconf
      ];
    };

    homePythonPackages = python-packages: with python-packages; [
      cookiecutter
      httpsig
      # ipython
      jedi
      pip
      pyaudio
      pylint
      pyserial
      requests
      setuptools
      ueberzug
      urllib3
      virtualenv
    ];

    homePython38 = python38Full.withPackages homePythonPackages;
  in
  [
    (
      writeShellScriptBinAndSymlink "nvidia-offload" ''
        export __NV_PRIME_RENDER_OFFLOAD=1
        export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
        export __GLX_VENDOR_LIBRARY_NAME=nvidia
        export __VK_LAYER_NV_optimus=NVIDIA_only
        exec -a "$0" "$@"
      ''
    )
    arandr
    (
      avahi.override {
        qt4Support = true;
        qt4 = qt4;
      }
    )
    bashInteractive
    bat # cat clone
    cadaver
    coreutils-full
    cyrus_sasl
    dmidecode
    dpt-rp1
    duff
    enscript
    fdupes
    feh
    ffmpeg-full
    file
    firefox
    fzf
    gftp
    glxinfo
    gnome3.gnome-font-viewer
    gnumake
    gocr
    homePython38
    hplip
    inetutils
    inkscape
    innoextract
    libsecret
    lsof
    lsscsi
    manpages
    # lutris
    mkpasswd
    mlterm
    ncurses
    nix-prefetch-git
    nodejs
    nodePackages.typescript
    # openssl
    pandoc
    patchelf
    pciutils
    pdftk
    perl
    psmisc
    pwgen
    pwsafe
    qrcode
    qutebrowser
    ranger
    ripgrep
    screen
    scummvm
    simple-scan
    smartmontools
    sxiv
    tabbed
    tcpdump
    tesseract4
    texlive.combined.scheme-full
    tigervnc
    tldr
    units
    unzip
    uqm
    usbutils
    # vimHugeX
    virt-viewer
    vulkan-tools
    winetricks
    wineWowPackages.stable
    wipe
    woeusb
    xclip
    xsel
    xorg.xdpyinfo
    xorg.xkill
    xournalpp
    yarn
    yubikey-personalization
    yubioath-desktop
    inotify-tools
  ];

  home.file.".XCompose".text = ''
  include "${emojiCompose.out}"
  include "%L"
  '';

  programs = {

    exa.enable = true;
    topgrade.enable = true;
    home-manager.enable = true;

    bash = {
      enable = true;
      historyControl = [ "ignorespace" ];
      historyIgnore = [ "mplayer" ];
      initExtra = ''
        GPG_TTY=$(tty)
      '';
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    browserpass = {
      enable = true;
      browsers = [
        "chrome"
        "firefox"
      ];
    };

    powerline-go = {
      enable = true;
    };

    aria2.enable = true;
  };

  services = {
    network-manager-applet.enable = true;
  };

  xdg = {
    enable = true;
    mimeApps = {
      defaultApplications = {
        "x-scheme-handler/ftp" = [ "gftp.desktop" ];
      };
    };
  };

  xsession = {
    enable = true;
  };

}
