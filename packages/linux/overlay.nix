final: _prev: {
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
}
