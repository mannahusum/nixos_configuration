{ pkgs, ... }:

{
  home.packages = 
  let
    newpkgs = import pkgs.path { overlays = [ (self: super: {
      myCalibre = super.calibre.overrideAttrs (
        oldAttrs: rec {
          buildInputs = oldAttrs.buildInputs ++ (
            with self.python38.pkgs; [
              pkgs.xdg_utils
              tkinter
              zeroconf
            ]
          );
        }
      );
    } ) ]; };
  in [
    newpkgs.myCalibre
  ];
}

