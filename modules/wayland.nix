{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.cawayland;

  windows-theme-gtk = pkgs.stdenv.mkDerivation {
    name = "B00merang-Project-Windows-Theme";
    version = "3.2.1";

    src = pkgs.fetchFromGitHub {
      owner = "B00merang-Project";
      repo = "Windows-10";
      rev = "3.2.1";
      hash = "sha256-O8sKYHyr1gX1pQRTTSw/kHREJ5MujbVjmLHJHbrUcRM=";
    };

    installPhase = ''
      mkdir -p "$out/share/themes/Windows-10"
      cp -r * "$out/share/themes/Windows-10"
    '';
  };

  windows-theme-icons = pkgs.stdenv.mkDerivation {
    name = "B00merang-Project-Windows-Icons";
    version = "1.0";

    src = pkgs.fetchFromGitHub {
      owner = "B00merang-Artwork";
      repo = "Windows-10";
      rev = "1.0";
      hash = "sha256-Yz6a7FcgPfzz4w8cKp8oq7/usIBUUZV7qhVmDewmzrI=";
    };

    installPhase = ''
      mkdir -p "$out/share/icons/Windows-10"
      cp -r * "$out/share/icons/Windows-10"
    '';
  };
  # my-windows11-latin-fonts = pkgs.stdenvNoCC.mkDerivation {
  #   pname = "windows11-latin-fonts";
  #   version = "1";
  #   src = pkgs.requireFile {
  #     url = "Via script from C:\\Windows\\fonts";
  #     sha256 = "1npq2zrdbmrqjp9slw3sfkz10wqr4cbxrq3sr50magr63d5gdghy";
  #   };
  # };
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
      ${pkgs.sway.out}/bin/sway --config ${myswayconfig} --unsupported-gpu
      ${pkgs.coreutils.out}/bin/sleep 60
    '';
  in
    lib.mkMerge [
      (lib.mkIf (cfg.displayManager == "regreet") {
        programs.sway = {
          enable = true;
          wrapperFeatures.gtk = true;
        };
        environment.etc."greetd/environments".text = ''
          sway
        '';
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
          cascadia-code
          gjs
          gnomeExtensions.appindicator
          gnomeExtensions.arcmenu
          gnomeExtensions.dash-to-panel
          gnomeExtensions.desktop-icons-ng-ding
          gnomeExtensions.topiconsfix
          gnomeExtensions.user-themes
          gnome-menus
          gnome-settings-daemon
          gnome-tweaks
          windows-theme-gtk
          windows-theme-icons
        ];
        hardware.sensor.iio.enable = true;
        programs = {
          dconf = {
            enable = true;
            profiles.user.databases = [
              {
                # lockAll = true; # prevents overriding
                settings = {
                  "org/gnome/settings-daemon/plugins/housekeeping" = {
                    "donation-reminder-enabled" = false;
                  };
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
                    update-notifier-project-version = lib.gvariant.mkInt32 69;
                  };
                  "org/gnome/shell/extensions/topicons" = {
                    tray-pos = "Center";
                    tray-order = "2";
                  };
                  "org/gnome/shell/extensions/dash-to-panel" = {
                    extended-version = lib.gvariant.mkInt32 72;
                    dot-style-focused = "DOTS";
                    dot-style-unfocused = "METRO";
                    multi-monitors = false;
                    panel-anchors = lib.gvariant.mkDictionaryEntry "LGD-0x100000a1" (lib.gvariant.mkVariant "MIDDLE");
                    panel-element-positions = ''{"LGD-0x100000a1":[{"element":"showAppsButton","visible":false,"position":"stackedTL"},{"element":"activitiesButton","visible":false,"position":"stackedTL"},{"element":"leftBox","visible":true,"position":"stackedTL"},{"element":"taskbar","visible":true,"position":"stackedTL"},{"element":"centerBox","visible":true,"position":"stackedBR"},{"element":"rightBox","visible":true,"position":"stackedBR"},{"element":"dateMenu","visible":true,"position":"stackedBR"},{"element":"systemMenu","visible":true,"position":"stackedBR"},{"element":"desktopButton","visible":true,"position":"stackedBR"}],"FUS-YV9S836192":[{"element":"showAppsButton","visible":false,"position":"stackedTL"},{"element":"activitiesButton","visible":false,"position":"stackedTL"},{"element":"leftBox","visible":true,"position":"stackedTL"},{"element":"taskbar","visible":true,"position":"stackedTL"},{"element":"centerBox","visible":true,"position":"stackedBR"},{"element":"rightBox","visible":true,"position":"stackedBR"},{"element":"dateMenu","visible":true,"position":"stackedBR"},{"element":"systemMenu","visible":true,"position":"stackedBR"},{"element":"desktopButton","visible":true,"position":"stackedBR"}],"FUS-YV9S827794":[{"element":"showAppsButton","visible":false,"position":"stackedTL"},{"element":"activitiesButton","visible":false,"position":"stackedTL"},{"element":"leftBox","visible":true,"position":"stackedTL"},{"element":"taskbar","visible":true,"position":"stackedTL"},{"element":"centerBox","visible":true,"position":"stackedBR"},{"element":"rightBox","visible":true,"position":"stackedBR"},{"element":"dateMenu","visible":true,"position":"stackedBR"},{"element":"systemMenu","visible":true,"position":"stackedBR"},{"element":"desktopButton","visible":true,"position":"stackedBR"}]}'';
                    panel-position = "BOTTOM";
                    location-clock = "STATUSRIGHT";
                  };
                  "org/gnome/shell/extensions/user-theme" = {
                    name = "Windows-10";
                  };
                  "org/gnome/shell" = {
                    welcome-dialog-last-shown-version = "49.2";
                  };
                  "org/gnome/desktop/a11y" = {
                    always-show-universal-access-status = true;
                  };
                  "org/gnome/desktop/a11y/applications" = {
                    screen-keyboard-enabled = true;
                  };
                  "org/gnome/desktop/interface" = {
                    gtk-theme = "Windows-10";
                    icon-theme = "Windows-10";
                    toolkit-accessibility = true;
                  };
                  "org/gnome/desktop/wm/preferences" = {
                    button-layout = ":minimize,maximize,close";
                  };
                };
              }
            ];
          };
          gnome-disks.enable = true;
        };
      })
      {
        programs = {
          ausweisapp = {
            enable = true;
            openFirewall = true;
          };
          browserpass.enable = true;
          # captive-browser.enable = true;
          firefox = {
            enable = true;
            languagePacks = [
              "de"
              "en-US"
              "es-ES"
              "fi"
              "fr"
              "sv-SE"
            ];
          };
          system-config-printer.enable = true;
          thunderbird.enable = true;
          traceroute.enable = true;
          wshowkeys.enable = true;
        };
        environment = {
          sessionVariables.NIXOS_OZONE_WL = "1";
          systemPackages = with pkgs; [
            wdisplays
            solarc-gtk-theme
            fira-code
          ];
        };

        causers.regularUserGroups = ["input"];
        nixpkgs.config.pulseaudio = true;
      }
    ]);
}
