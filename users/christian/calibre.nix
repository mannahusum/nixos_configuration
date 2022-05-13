{ pkgs, ... }:

{
  home.packages =
  let
    kindle_installer = (builtins.fetchurl {
      url = "https://s3.amazonaws.com/kindleforpc/61109/KindleForPC-installer-1.32.61109.exe";
      sha256 = "0y1wqwhav3briibx7vfcgai4psysq6v33iz0ghy4sg8nfcdpq0hx";
    });
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
    chocolatey = (builtins.fetchurl {
      url = "https://raw.githubusercontent.com/PietJankbal/Chocolatey-for-wine/main/chocinstaller.exe";
      sha256 = "08dyap3sr6s0pwg333i3bq21nrb8d2zz44c2xynvvbjxxxlb7xwa";
    });
    python38win32 = (builtins.fetchurl {
      url = "https://www.python.org/ftp/python/3.8.9/python-3.8.9.exe";
      sha256 = "1r8lzlmxrfx7gyxq1sczwfkrzvvvkwpcdw7858mzjbsa4fdwrkhf";
    });
    python27win32 = (builtins.fetchurl {
      url = "https://www.python.org/ftp/python/2.7.13/python-2.7.13.msi";
      sha256 = "0yh1yqpiq2lfrg0jxvm19p4vzc49awl9d1q5llc5n6b5ccsrbsj4";
    });
  in let
    kindle = nur.repos.lucasew.packages.wrapWine {
      name = "Kindle";
      # tricks = [
      #   "kindle"
      #   "python27"
      # ];
      firstrunScript = ''
        wine ${python38win32} /quiet InstallAllUsers=1 PrependPath=1
        ln -s /home $WINEPREFIX/drive_c/home
        winetricks kindle
      '';
      executable = "$WINEPREFIX/drive_c/Program Files/Amazon/Kindle/Kindle.exe";
    };

    newpkgs = import pkgs.path { overlays = [ (self: super: {
      myCalibre = super.calibre.overrideAttrs (
        oldAttrs: rec {
          buildInputs = oldAttrs.buildInputs ++ (
            with self.python38.pkgs; [
              pkgs.xdg_utils
              pycrypto
              pyqt5
              sip
              tkinter
              zeroconf
            ]
          );
        }
      );
    } ) ]; };
  in [
    # newpkgs.myCalibre
    pkgs.calibre
    kindle
  ];
}

