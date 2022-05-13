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

      # used by vim
      black
      simple-websocket-server
      python-slugify

      # needed by black, hope this helps
      pathspec
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

    autorandr = {
      enable = true;
      hooks.postswitch = {
        "notify-awesome" = "echo 'awesome.restart()' | ${pkgs.awesome.out}/bin/awesome-client";
        "change-dpi" = ''
          case "$AUTORANDR_CURRENT_PROFILE" in
            default)
              DPI=130;
              ;;
            docked)
              DPI=163;
              ;;
            *)
              echo "Unknown profile: $AUTORANDR_CURRENT_PROFILE"
              exit 1
              ;;
          esac

          echo "Xft.dpi: $DPI" | ${pkgs.xorg.xrdb}/bin/xrdb -merge
        '';
      };
      profiles = {
        "docked" = {
          fingerprint = {
            "DP-2-1" = "00ffffffffffff0010ac08a04c383830280f010380291f78ee6390a3574b9b25115054a54b008180a940714f01010101010101010101483f403062b0324040c013006f131100001e000000ff0043303838313539533038384c20000000fc0044454c4c203230303146500a20000000fd00384c1f5010000a2020202020200053";
            "DP-2-2" = "00ffffffffffff001e6d0677e28f0300061d0103803c2278ea3e31ae5047ac270c50542108007140818081c0a9c0d1c081000101010104740030f2705a80b0588a0058542100001a04740030f2705a80b0588a0058542100001a000000fd00383d1e873c000a202020202020000000fc004c472048445220344b0a20202001e3020338714d9022201f1203040161605d5e5f230907076d030c001100b83c20006001020367d85dc401788003e30f0003e305c000e3060501023a801871382d40582c450058542100001e565e00a0a0a029503020350058542100001a000000ff003930364e54585236563434320a0000000000000000000000000000000000c5";
            "eDP-1" = "00ffffffffffff0006afed3400000000001601049522137802d1159e59539b271e505400000001010101010101010101010101010101b03680b470381e403064310058c1100000180000000f0000000000000000000000000020000000fe0041554f0a202020202020202020000000fe004231353648544e30332e34200a00f6";
          };
          config = {
            "eDP-1".enable = false;
            "DP-2-1" = {
              enable = true;
              crtc = 0;
              primary = true;
              position = "0x0";
              mode = "1600x1200";
              rate = "60.00";
              transform = [
                [ 1.699997 0.000000 0.000000 ]
                [ 0.000000 1.699997 0.000000 ]
                [ 0.000000 0.000000 1.000000 ]
              ];
            };
            "DP-2-2" = {
              enable = true;
              crtc = 2;
              mode = "38640x2160";
              position = "2720x0";
              rate = "30.00";
            };
          };
        };
      };
    };
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
