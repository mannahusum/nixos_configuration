{ pkgs, home, xdg, ... }:
let
  office = pkgs.libreoffice-fresh-unwrapped;
in {
  home.packages = with pkgs; [
    office
  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/vnd.openxmlformats-officedocument.wordprocessingm" =
        [ "libreoffice-writer.desktop" ];
    };
  };

  home.sessionVariables = {
    PYTHONPATH = "${office}/lib/libreoffice/program";
    URE_BOOTSTRAP = "vnd.sun.star.pathname:${office}/lib/libreoffice/program/fundamentalrc";
  };
}
