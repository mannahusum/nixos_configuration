{ pkgs, home, xdg, programs, ... }:

let
  get_password_command = account: "${pkgs.pass.out}/bin/pass \"${account}\" | head -n 1";
  get_username_command = account: "${pkgs.pass.out}/bin/pass \"${account}\" | ${pkgs.gnugrep}/bin/grep ^user: | ${pkgs.coreutils}/bin/cut -d\\  -f2";
  spotify = "spotify.com";
  # spotify_playerctl_notification = {
  #   name = "spotifyd_playerctl_notification";

  #   src = pkgs.fetchFromGitHub {
  #     owner = "robn";
  #     repo = "sasl2-oauth";
  #     rev = "4236b6fb904d836b85b55ba32128b843fd8c2362";
  #     hash = "sha256:4236b6fb904d836b85b55ba32128b843fd8c2362";
  #   };

  #   depsBuildBuild = [
  #     autoconf automake gcc libtool pkg-config ];

  #   nativeBuildInputs = [ autoreconfHook pruneLibtoolFiles ];

  #   # buildInputs = [ cyrus_sasl ];

  #   # prePatch = ''
  #   #   find . -type f -exec grep -H /usr/bin/perl {} ';' | cut -d: -f1 | xargs sed -i 's,/usr/bin/perl,${perl}/bin/perl,'
  #   # '';

  #   meta = {
  #     homepage = "https://github.com/robn/sasl2-oauth";
  #     description = "OAUTH-plugin for cyrus_sasl";
  #   };

  # };
in let
  tomlFormat = pkgs.formats.toml { };
  spotifyConfig = tomlFormat.generate "spotifyd.conf" {
      global = {
        username_cmd = get_username_command spotify;
        password_cmd = get_password_command spotify;
        device_name = "mannahusum";
        backend = "pulseaudio";
        use_mpris = true;
        cache = (builtins.getEnv "HOME") + "/spotifyd";
        no_audio_cache = false;
        device_type = "computer";
      };
    };
in {

  nixpkgs.overlays = [
    (self: super: {
        spotifyd = super.spotifyd.override {
          withMpris = true;
        };
        pythonPackages = super.python38Packages;
      }
    )
    (_: prev: {

      prev.linuxPackagesFor = kernel:
        (prev.linuxPackagesFor kernel).extend (_: _: { ati_drivers_x11 = null; });

    })
  ];

  home.packages = with pkgs; [
    ardour
    fluidsynth
    pavucontrol
    playerctl
    ( qt5.callPackage ./pianobooster.nix {} )
    rosegarden
    soundfont-fluid
    timidity
    spotify-tui
  ];

  programs.ncspot.enable = true;
  services = {
    fluidsynth.enable = true;
    playerctld.enable = true;
  };

  xdg.enable = true;

  systemd.user.services.spotifyd = {
    Unit = {
      Description = "spotify daemon";
      Documentation = "https://github.com/Spotifyd/spotifyd";
    };

    Install.WantedBy = [ "default.target" ];

    Service = {
      Environment="SPOTIFYD_CLIENT_ID=6ae373fc497545af9002cc6c988118b8";
      ExecStart =
        "${pkgs.spotifyd}/bin/spotifyd --no-daemon --config-path ${spotifyConfig}";
      Restart = "always";
      RestartSec = 12;
    };
  };
}

