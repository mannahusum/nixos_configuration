final: prev: {
  disktype = final.callPackage ./disktype.nix {};

  mf660cppd = let
    ppd = final.requireFile {
      name = "CNRCUPSMF660CZK.ppd";
      url = "https://www.canon.de/support/consumer/products/printers/i-sensys/mf-series/i-sensys-mf655cdw.html";
      hash = "sha256-4gT9guRdHo37Lmb0vi0Fj2y1Ob2gqDLskhHo9FS+t/U=";
    };
  in
    final.stdenv.mkDerivation {
      name = "mfc660cppd";
      pname = "mfc660cppd";
      src = ppd;
      dontUnpack = true;
      doCheck = false;
      installPhase = ''
        mkdir -p "''${out}/share/cups/model/"
        cp ${ppd} "''${out}/share/cups/model/CNRCUPSMF660CZK.ppd"
      '';
      meta = {
        homepage = "https://www.canon.de/support/consumer/products/printers/i-sensys/mf-series/i-sensys-mf655cdw.html";
        description = "Printer Driver for my moms printer";
        platforms = final.lib.platforms.all;
      };
    };
    dpt-rp1-py = let
      version = "0.1.20";
      sha256 = "sha256-d3SvKtoEq0+Ojs0jy8xWsiErFpKNVL0g8lfUTjYJww8=";
    in prev.dpt-rp1-py.overrideAttrs (
      _finalAttrs: _previousAttrs: {
        inherit version;
        src = final.fetchFromGitHub {
          inherit sha256;
          owner = "janten";
          repo = "dpt-rp1-py";
          rev = "v${version}";
        };
      }
    );

}
