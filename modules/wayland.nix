{ config, modulesPath, lib, pkgs, nixpkgs, time, i28n, sound, hardware, ... }:
let
  cfg = config.cawayland;
in {
  imports = [
    ./users.nix
  ];

  options.cawayland = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether you want to run display manager and user guis in wayland
      '';
    };
    keyboardSettings = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = ''
        Keyboard settings used for wayland sessions, e.g. greetd
      '';
    };
  };

  config = lib.mkIf cfg.enable (let
    mycage = let
      mygtkgreet = let
        mywaydispconf = pkgs.writeText "cfg.yaml" ''
          ARRANGE: ROW
          ALIGN: MIDDLE
          ORDER:
            - 'DP-1'
            - 'HDMI-A-1'
          SCALING: true
          AUTO_SCALE: true
          crashes cage somehow
          ''${pkgs.way-displays}/bin/way-displays -c ''${mywaydispconf} &
        '';
      in pkgs.writeShellScriptBin "mygtkgreet" ''
          ${pkgs.greetd.gtkgreet}/bin/gtkgreet
        '';
    in pkgs.writeShellScriptBin "mycage" ''
      ${cfg.keyboardSettings}
      ${pkgs.cage}/bin/cage \
        -m last \
        -- ${mygtkgreet.out}/bin/mygtkgreet

    '';
  in {
    nixpkgs.overlays = [
      (
        final: prev: {
          cage = if (builtins.compareVersions prev.cage.version "0.1.5") == -1 then
            (prev.cage.overrideAttrs (
              previousAttrs: rec {
                version = "0.1.5";
                src = prev.fetchFromGitHub {
                  owner = "Hjdskes";
                  repo = "cage";
                  rev = "v${version}";
                  hash = "sha256-Suq14YRw/MReDRvO/TQqjpZvpzAEDnHUyVbQj0BPT4c=";
                };
                buildInputs = previousAttrs.buildInputs ++ [ prev.xorg.xcbutilwm ];
                CFLAGS = null;
              }
            )).override( { wlroots = final.wlroots; }) else prev.cage;
          wlroots = if (builtins.compareVersions prev.wlroots.version "0.16") == -1 then
            (prev.wlroots.overrideAttrs (
              previousAttrs: rec {
                version = "0.16.2";
                src = prev.fetchFromGitLab {
                  domain = "gitlab.freedesktop.org";
                  owner = "wlroots";
                  repo = "wlroots";
                  rev = version;
                  hash = "sha256-JeDDYinio14BOl6CbzAPnJDOnrk4vgGNMN++rcy2ItQ=";
                };
                postPatch = ''
                  substituteInPlace backend/drm/meson.build \
                    --replace /usr/share/hwdata/ ${prev.hwdata}/share/hwdata/
                '';
                buildInputs = previousAttrs.buildInputs ++ [ prev.vulkan-loader prev.xorg.xcbutilwm ];
                nativeBuildInputs = previousAttrs.nativeBuildInputs ++ [ prev.glslang ];
              }
            )) else prev.wlroots;
          way-displays = if (builtins.compareVersions prev.way-displays.version "1.9.0") == -1 then
            (prev.way-displays.overrideAttrs (
              previousAttrs: rec {
                version = "1.9.0";
                src = prev.fetchFromGitHub {
                  owner = "alex-courtis";
                  repo = "way-displays";
                  rev = version;

                  sha256 = "sha256-X+/aM+/2pO1FbHGwEiC2w9AxPXHf1EVZkyr+CXtprLk=";
                };
              }
            )) else prev.way-displays;
        }
      )
    ];
    services.greetd = {
      enable = true;
      settings = {
        default_session.command = "${mycage.out}/bin/mycage";
      };
    };
    environment.etc."greetd/environments".text = ''
      sway
    '';

    environment.systemPackages = [
      pkgs.cage
    ];
    causers.regularUserGroups = [ "input" ];
    programs.sway.enable = true;

    sound.enable = true;
    nixpkgs.config.pulseaudio = true;
    hardware.pulseaudio.enable = true;
  });
}

