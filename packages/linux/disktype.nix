{
  lib,
  pkgs,
  stdenv,
}: let
  version = "9";
  name = "disktype";
in stdenv.mkDerivation {
  inherit version;
  pname = name;
  src = pkgs.fetchurl {
    url = "mirror://sourceforge/${name}/${name}-${version}.tar.gz";
    hash = "sha256-tnASVNiEErxdLbhpA3dF9l+UuQC1kYQVfQcvNYMsERE=";
  };
  doCheck = false;
  installPhase = ''
    mkdir -p "''${out}/bin"
    cp disktype "''${out}/bin/"
  '';
  meta = {
    homepage = "https://disktype.sourceforge.net/";
    description = "Tool to analyse the type of disk you are dealing with";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "disktype";
  };
}

