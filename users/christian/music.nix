{ pkgs, ... }:

{
  home.packages = with pkgs; [
    ardour
    fluidsynth
    pavucontrol
    ( qt5.callPackage ./pianobooster.nix {} )
    rosegarden
    soundfont-fluid
    timidity
  ];
  services.fluidsynth.enable = true;
}

