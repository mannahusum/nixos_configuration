{ pkgs, home, nixpkgs, lib, ... }:
with lib;

{
  nixpkgs.overlays = [
    (self: super: {
        mplayer = super.mplayer.override {
          pulseSupport = true;
          libpulseaudio = super.pulseaudio;
          vdpauSupport = true;
          libvdpau = super.libvdpau;
        };
      }
    )
  ];

  home.packages = with pkgs; let
    writeShellScriptBinAndSymlink = name: text: symlinkJoin {
      name = name;
      paths = [
        (writeShellScriptBin name text)
      ];
    };

  in [
    (writeShellScriptBinAndSymlink "youtube-pl" ''
      ${mplayer.out}/bin/mplayer -cache 30720 -cache-min 2 <(${youtubeDL.out}/bin/youtube-dl -q -o- $@)
    '')
    mplayer
    youtube-dl
    dvdbackup
    dvdplusrwtools
  ];

  home.file.".mplayer/config" = {
    text = ''
      ao=pulse
      heartbeat-cmd="${pkgs.xscreensaver.out}/bin/xscreensaver-command -deactivate &"
    '';
  };

  programs.bash = {
    historyIgnore = [ "mplayer" ];
  };
}
