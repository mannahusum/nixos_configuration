{
  lib,
  pkgs,
  ...
}: {
  imports = [
  ];

  options.ca.sway = {
    enable = lib.mkEnableOption "Generate Sway configuration";
  };

  config = let
    image = pkgs.fetchurl {
      url = "https://upload.wikimedia.org/wikipedia/commons/9/9a/Stevia_plant.jpg";
      sha256 = "1p15zlvrrayp0r4qpa4154kw12x4g9g8hyilwzv50xd0h4y736cf";
    };
    modifier = "Mod4";
    bemenu = "${lib.getExe' pkgs.bemenu "bemenu-run"}";
    shotman = "${pkgs.shotman.out}/bin/shotman";
    zenity = "${pkgs.zenity.out}/bin/zenity";
  in {
    home.sessionVariables = {
      XKB_DEFAULT_LAYOUT = "de,de,gr";
      XKB_DEFAULT_MODEL = "pc105";
      XKB_DEFAULT_VARIANT = "neo,,";
      XKB_DEFAULT_OPTIONS = ",,";
      NIXOS_OZONE_WL = 1;
    };
    programs.swaylock = {
      enable = true;
      settings = {
        ignore-empty-password = true;
        show-failed-attempts = true;
        image = "${image.out}";
        show-keyboard-layout = true;
        scaling = "stretch";
      };
    };
    services.swayidle = {
      enable = true;
      timeouts = [
        {
          timeout = 300;
          command = "${pkgs.swaylock}/bin/swaylock -f";
        }
        {
          timeout = 600;
          command = "${pkgs.sway}/bin/swaymsg output * power off";
        }
      ];
      events = [
        {
          event = "before-sleep";
          command = "${pkgs.swaylock}/bin/swaylock -f";
        }
        {
          event = "after-resume";
          command = "${pkgs.sway}/bin/swaymsg output * power on";
        }
      ];
    };

    wayland.windowManager.sway = {
      enable = true;
      config = {
        inherit modifier;

        menu = bemenu;
        terminal = "${pkgs.alacritty.out}/bin/alacritty";
        keybindings = lib.mkOptionDefault {
          "${modifier}+Shift+e" = "exec ${zenity} --question --text='You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' && swaymsg exit";
          "${modifier}+p" = "exec ${shotman} --capture window";
          "${modifier}+Shift+p" = "exec ${shotman} --capture region";
          "${modifier}+Ctrl+p" = "exec ${shotman} --capture output";
        };
      };
      extraSessionCommands = ''
               XKB_DEFAULT_LAYOUT="de,de,gr";
               XKB_DEFAULT_MODEL="pc105";
               XKB_DEFAULT_VARIANT="neo,,";
               XKB_DEFAULT_OPTIONS=",,";
        WLR_RENDERER=vulkan;
      '';
      extraConfig = ''
        input "type:keyboard" {
          xkb_layout de,de,gr
          xkb_model pc105
          xkb_variant neo,,
          xkb_options ,,
        }
      '';
    };
    fonts.fontconfig.enable = true;
    home.packages = with pkgs;
      [
        alacritty
        grim
        imv
        mako
        mpv
        neovide
        wayland
        wl-clipboard
        xdg-utils
      ]
      ++ (builtins.filter lib.attrsets.isDerivation (builtins.attrValues nerd-fonts));
  };
}
