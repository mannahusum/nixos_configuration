{ pkgs, home, xdg, programs, config, ... }:

let
  get_password_command = account: "${pkgs.pass.out}/bin/pass \"${account}\" | ${pkgs.coreutils}/bin/head -n 1";
  get_username_command = account: "${pkgs.pass.out}/bin/pass \"${account}\" | ${pkgs.gnugrep}/bin/grep ^user: | ${pkgs.coreutils}/bin/cut -d\\  -f2";
  spotify = "spotify.com";
in let
  tomlFormat = pkgs.formats.toml { };
  spotifyConfig = tomlFormat.generate "spotifyd.conf" {
      global = {
        username_cmd = get_username_command "spotify.com";
        password_cmd = get_password_command "spotify.com";
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
      BindsTo = [ (config.services.fluidsynth.soundService + ".service") ];
      After = [ (config.services.fluidsynth.soundService + ".service") ];
    };

    Install.WantedBy = [ "default.target" ];

    Service = {

      Environment= [
        "SPOTIFYD_CLIENT_ID=6ae373fc497545af9002cc6c988118b8"
        "PASSWORD_STORE_DIR=${config.programs.password-store.settings.PASSWORD_STORE_DIR}"
      ];
      ExecStart =
        "${pkgs.spotifyd}/bin/spotifyd --no-daemon --config-path ${spotifyConfig}";
      Restart = "always";
      RestartSec = 12;
    };
  };
}

