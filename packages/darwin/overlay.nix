self: super: {
  neolayout = self.stdenv.mkDerivation {
    pname = "neo-layouts";
    version = "0";
    src = self.fetchurl {
      url = "https://dl.neo-layout.org/neo-layouts.dmg";
      hash = "sha256-4kTXjWHp5EnQuaTyMWshCOwZCImWh7vMmIDRxOUg50U=";
    };
    meta = {
      description = "Neo is an ergonomic keyboard layout optimized for the German language";
      homepage = "https://neo-layout.org/";
      maintainers = [
        {
          email = "christian@wudika.de";
          github = "mannahusum";
          githubId = 223651;
          name = "Christian Albertsen";
        }
      ];
      platforms = [
        "x86_64-darwin"
        "aarch64-darwin"
      ];
    };

    nativeBuildInputs = with self; [_7zz];

    unpackPhase = ''
      7zz x $src
    '';

    installPhase = ''
      mkdir -p $out
      cp -r neo-layouts.bundle $out/neo-layouts.bundle
    '';
  };

  ssh_askpass = let
    version = "1.5.1";
  in
    self.stdenv.mkDerivation {
      inherit version;
      pname = "ssh-askpass";
      src = self.fetchFromGitHub {
        owner = "theseal";
        repo = "ssh-askpass";
        rev = "v${version}";
        hash = "sha256-AIavOodSuRjCuZE6XRTi86sdLdrLwQyMNwpy8FEx0Ak=";
      };
      dontBuild = true;

      installPhase = ''
        mkdir -p $out/bin
        cp ssh-askpass $out/bin/ssh-askpass

        mkdir -p $out/Library/LaunchDaemons
        cp ${./com.github.theseal.ssh-askpass.plist} $out/Library/LaunchDaemons/com.github.theseal.ssh-askpass.plist
        substituteInPlace $out/Library/LaunchDaemons/com.github.theseal.ssh-askpass.plist --subst-var out
      '';

      meta = with self.lib; {
        description = "ssh-askpass for OS X/macOS";
        homepage = "https://github.com/theseal/ssh-askpass";
        downloadPage = "https://github.com/theseal/ssh-askpass/releases";
        platforms = platforms.darwin;
        mainProgram = "ssh-askpass";
      };
    };

  epsonscan2 = {
    pname = "epsonscan2";
    src = self.fetchurl {
      url = "https://download.epson-europe.com/pub/download/6747/epson674793eu.dmg";
      hash = "sha256-Dzf0X4apccIE/M8EJs8V0VBxTIl8A6snKoJUsL3E/MY=";
    };
    meta = {
      description = "Scanner software for some Epson Scanners like DS-1660W";
      homepage = "https://www.epson.de/de_DE/support/sc/epson-workforce-ds-1660w/s/s1492?selected-tab=&selected-os=macOS+Tahoe+26";
      maintainers = [
        {
          email = "christian@wudika.de";
          github = "mannahusum";
          githubId = 223651;
          name = "Christian Albertsen";
        }
      ];
      platforms = [
        "aarch64-darwin"
      ];
    };

    nativeBuildInputs = with self; [xar];

    unpackPhase = ''
      7zz x $src
    '';

    installPhase = ''
      mkdir -p $out
      find . -name Payload -exec tar -c "$out/" -xzvf '{}' ';'
    '';
  };
}
