{ pkgs, ... }:

{
  home.packages = with pkgs; let
    mnemosyne = pkgs.mnemosyne.overrideAttrs (
      oldAttrs: rec {
        buildInputs = oldAttrs.buildInputs ++ [ pkgs.ffmpeg pkgs.lilypond ];
        prePatch = oldAttrs.prePatch + ''
          find . -type f -exec grep -H /usr/bin/python {} ';' | cut -d: -f1 | xargs sed -i 's,/usr/bin/python,/usr/bin/env python,'
        '';
      }
    );
  in [
    mnemosyne
  ];
}
