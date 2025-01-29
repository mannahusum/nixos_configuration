{
  config,
  lib,
  pkgs,
  ...
}: let
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
        cursor_theme_name = lib.mkForce "SolArc";
        font_name = lib.mkForce "FiraCode Nerd Font 11";
        icon_theme_name = lib.mkForce "SolArc";
        theme_name = lib.mkForce "SolArc";
      };
    };

    myswayconfig = pkgs.writeText "greetd-sway-config" ''
      # `-l` activates layer-shell mode. Notice that `swaymsg exit` will run after gtkgreet.
      exec "${pkgs.greetd.regreet.out}/bin/regreet; swaymsg exit"

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
      wdisplays
      solarc-gtk-theme
      fira-code
    ];

    causers.regularUserGroups = ["input"];
    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };
    programs.regreet = {
      enable = true;
      settings = myregreetconfig;
    };

    nixpkgs.config.pulseaudio = true;
  });
}
