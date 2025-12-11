{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.cawayland;
  windows-theme = pkgs.fetchFromGitHub {
    owner = "B00merang-Project";
    repo = "Windows-10";
    rev = "3.2.1";
  };
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
    displayManager = lib.mkOption {
      type = lib.types.enum ["regreet" "gdm"];
      default = "regreet";
      description = ''
        Which displayManager to use for login
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
      exec "${pkgs.lib.getExe' pkgs.regreet "regreet"}; swaymsg exit"

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
  in
    lib.mkMerge [
      (lib.mkIf (cfg.displayManager == "regreet") {
        services.greetd = {
          enable = true;
          settings = {
            default_session.command = "${myswaycommand.out}/bin/mysway";
          };
        };
        programs.regreet = {
          enable = true;
          settings = myregreetconfig;
        };
        causers.defaultPinentry = "bemenu";
      })
      (lib.mkIf (cfg.displayManager == "gdm") {
        services = {
          displayManager = {
            gdm.enable = true;
            sessionPackages = [
              (
                (
                  pkgs.writeTextDir "share/wayland-sessions/sway.desktop" ''                    [Desktop Entry]
                    Name=Sway
                    Comment=Sway run from a login shell
                    Exec=${pkgs.dbus}/bin/dbus-run-session -- bash -l -c sway
                    Type=Application''
                ).overrideAttrs (oldAttrs: rec {
                  passthru = {
                    providedSessions = ["sway"];
                  };
                })
              )
            ];
          };
          desktopManager.gnome.enable = true;
        };
        causers.defaultPinentry = "gnome3";
        environment.systemPackages = with pkgs; [
          adwaita-icon-theme
          gjs
          gnomeExtensions.appindicator
          gnomeExtensions.arcmenu
          gnomeExtensions.dash-to-panel
          gnomeExtensions.desktop-icons-ng-ding
          gnomeExtensions.topiconsfix
          gnomeExtensions.user-themes
          gnome-menus
          gnome-settings-daemon
        ];
        hardware.sensor.iio.enable = true;
        programs.dconf.enable = true;
        programs.dconf.profiles.user.databases = [
          {
            # lockAll = true; # prevents overriding
            settings = {
              "org/gnome/shell" = {
                enabled-extensions = [
                  "appindicatorsupport@rgcjonas.gmail.com"
                  "arcmenu@arcmenu.com"
                  "dash-to-panel@jderose9.github.com"
                  "ding@rastersoft.com"
                  "topiconsfix@aleskva@devnullmail.com"
                  "user-theme@gnome-shell-extensions.gcampax.github.com"
                ];
                favorite-apps = [
                  "org.gnome.Nautilus.desktop"
                  "google-chrome.desktop"
                  "Alacritty.desktop"
                  "neovide.desktop"
                ];
              };
              "org/gnome/shell/extensions/arcmenu" = {
                position-in-panel = "Left";
                multi-monitor = true;
                menu-layout = "Windows";
                menu-button-appearance = "Icon";
                windows-layout-extra-shortcuts = lib.gvariant.mkArray [
                  (lib.gvariant.mkDictionaryEntry "id" (lib.gvariant.mkVariant "org.gnome.Nautilus.desktop"))
                  (lib.gvariant.mkDictionaryEntry "id" (lib.gvariant.mkVariant "Alacritty.desktop"))
                  (lib.gvariant.mkDictionaryEntry "id" (lib.gvariant.mkVariant "org.gnome.Settings.desktop"))
                ];
              };
              "org/gnome/shell/extensions/topicons" = {
                tray-pos = "Center";
                tray-order = "2";
              };
              "org/gnome/shell/extensions/dash-to-panel" = {
                panel-position = "BOTTOM";
                location-clock = "STATUSRIGHT";
              };
              "org/gnome/desktop/wm/preferences" = {
                button-layout = ":minimize,maximize,close";
              };
            };
          }
        ];
      })
      {
        environment.etc."greetd/environments".text = ''
          sway
        '';
        environment.systemPackages = with pkgs; [
          wdisplays
          solarc-gtk-theme
          fira-code
        ];

        programs.sway = {
          enable = true;
          wrapperFeatures.gtk = true;
        };
        causers.regularUserGroups = ["input"];

        nixpkgs.config.pulseaudio = true;
      }
    ]);
}
