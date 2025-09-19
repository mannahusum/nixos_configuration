{nixpkgs ? (import <nixpkgs> {})}: let
  stdenv = nixpkgs.stdenv;
  lib = nixpkgs.lib;
  unzip = nixpkgs.unzip;
in
  stdenv.mkDerivation {
    name = "cups-kyocera5012cdw";

    # Source Code
    # See: https://nixos.org/nixpkgs/manual/#ssec-unpack-phase
    src = ./Linux_8.1602_ECOSYS_M5521_5526_P5021_5026.zip;

    # Dependencies
    # See: https://nixos.org/nixpkgs/manual/#ssec-stdenv-dependencies
    buildInputs = [unzip];

    # Build Phases
    # See: https://nixos.org/nixpkgs/manual/#sec-stdenv-phases
    unpackPhase = ''
      unzip -x $src
    '';

    dontBuild = true;

    installPhase = ''
      mkdir -p $out/share/cups/model/Kyocera
      cd Linux/EU/German
      for ppd in *.PPD; do
        cp "$ppd" "$out/share/cups/model/Kyocera/"
      done
    '';

    meta = with lib; {
      description = "CUPS drivers for several Kyocera ECOSYS printers";
      homepage = "https://www.kyoceradocumentsolutions.ru/index/service_support/download_center.false.driver.FS1040._.EN.html#";
      # license = licenses.unfree;
      platforms = platforms.linux;
    };
  }
