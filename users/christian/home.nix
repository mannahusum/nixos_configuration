{ pkgs, config, lib, nixpkgs, ... }:
with lib;

{

  # inherit nixpkgs;

  home.keyboard = null;

  imports = [
    ./fontconfig.nix

    ./alacritty.nix
    ./awesome.nix
    ./calibre.nix
    ./email.nix
    ./git.nix
    ./google-chrome.nix
    # ./kitty.nix
    ./mnemosyne.nix
    ./music.nix
    ./mplayer.nix
    ./passwordsafe.nix
    ./pulseaudio.nix
    ./qemu.nix
    ./ssh.nix
    ./taskwarrior.nix
    ./todoist.nix
    # ./sway.nix
    ./xscreensaver.nix
    ./zathura.nix
    ./vim.nix
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
      version = "0.1.11";

      src = python38.pkgs.fetchPypi {
        inherit pname version;
        sha256 = "0jy9fvmb6a3fcnijxk6xnss3k4c9pjffggr006xsvbig1lprcx5r";
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
    yubioath-desktop
    inotify-tools
  ];

  home.file.".XCompose".source = ./XCompose;

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
  };

  services = {
    network-manager-applet.enable = true;
  };

  xdg = {
    enable = true;
  };

  xsession = {
    enable = true;
  };

}
