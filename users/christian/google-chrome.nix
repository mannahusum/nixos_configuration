{ pkgs, xdg, xsession, ... }:
{
  home.packages = with pkgs; [
    (
      google-chrome.overrideAttrs (
        oldAttrs: {
          buildInputs = oldAttrs.buildInputs ++ [ pkgs.xorg.libxshmfence ];
        }
      )
    )
  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = [ "google-chrome.desktop" ];
      "x-scheme-handler/http" = [ "google-chrome.desktop" ];
      "x-scheme-handler/https" = [ "google-chrome.desktop" ];
      "x-scheme-handler/about" = [ "google-chrome.desktop" ];
      "x-scheme-handler/unknown" = [ "google-chrome.desktop" ];
    };
  };
}
