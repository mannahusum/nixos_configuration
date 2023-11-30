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
    mybackground = builtins.fetchurl {
      url = "https://upload.wikimedia.org/wikipedia/commons/0/00/Husum-NordseeMuseum_Nissenhaus.jpg";
      sha256 = "0b4qqmiz5lbqizhf2kfc2x22im59nvi0672cn3aanybmbm0vm3g7";
    };
    myregreetconfig = {
      background = {
        path = "${mybackground}";
        fit = "Contain";
      };
      GTK = {
        application_prefer_dark_theme = false;
        cursor_theme_name = "SolArc";
        font_name = "FiraCode Nerd Font 11";
        icon_theme_name = "SolArc";
        theme_name = "SolArc";
      };
    };


    myswayconfig = pkgs.writeText "greetd-sway-config" ''
# `-l` activates layer-shell mode. Notice that `swaymsg exit` will run after gtkgreet.
exec "${pkgs.greetd.regreet.out}/bin/regreet; swaymsg exit"

output "DP-1" mode 3840x2160@30Hz pos 0 0
output "HDMI-A-1" mode 1600x1200@60Hz pos 3840 0 scale 0.61

bindsym Mod4+shift+e exec swaynag \
-t warning \
-m 'What do you want to do?' \
-b 'Poweroff' 'systemctl poweroff' \
-b 'Reboot' 'systemctl reboot'

include /etc/sway/config.d/*
'';
  myswaycommand = pkgs.writeShellScriptBin "mysway" ''
${cfg.keyboardSettings}
${pkgs.sway.out}/bin/sway --config ${myswayconfig}
  '';
  in {
    services.greetd = {
      enable = true;
      settings = {
        default_session.command = "${myswaycommand.out}/bin/mysway";
      };
    };
    environment.etc."greetd/environments".text = ''
      sway
    '';
    environment.systemPackages = with pkgs; [
      solarc-gtk-theme
      fira-code
    ];

    causers.regularUserGroups = [ "input" ];
    programs.sway.enable = true;
    programs.regreet = {
      enable = true;
      settings = myregreetconfig;
    };

    sound.enable = true;
    nixpkgs.config.pulseaudio = true;
    hardware.pulseaudio.enable = true;
  });
}

