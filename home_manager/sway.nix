{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.ca.sway;
in {
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
    shotman = "${pkgs.shotman.out}/bin/shotman";
    swaylockcfg = pkgs.writeText "swaylock.cfg" ''
    '';
  in {
    home.sessionVariables = {
      XKB_DEFAULT_LAYOUT = "de,de,gr";
      XKB_DEFAULT_MODEL = "pc105";
      XKB_DEFAULT_VARIANT = "neo,,";
      XKB_DEFAULT_OPTIONS = ",,";
      NIXOS_OZONE_WL = 1;
      WLR_RENDERER = "vulkan";
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

        terminal = "${pkgs.alacritty.out}/bin/alacritty";
        keybindings = lib.mkOptionDefault {
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
    home.packages = with pkgs; [
      nerdfonts
      alacritty
      grim
      neovide
      wl-clipboard
      mako
      wayland
      xdg-utils
    ];
  };
}
