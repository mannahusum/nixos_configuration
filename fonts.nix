{ pkgs, fonts, ... }:
{
  fonts = {
    enableDefaultFonts = true;
    enableFontDir = true;
    enableGhostscriptFonts = true;

    fontconfig = {
      allowBitmaps = false;
      subpixel.rgba = "rgb";
    };

    fonts = with pkgs; [
      corefonts
      dina-font
      fira-code
      fira-code-symbols
      hasklig
      inconsolata
      liberation_ttf
      lmodern
      mplus-outline-fonts
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      proggyfonts
      source-code-pro
      symbola
      ubuntu_font_family
    ];
  };
}
