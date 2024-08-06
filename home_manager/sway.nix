{ config, lib, pkgs, ... }:
let
  cfg = config.ca.sway;
in {
  imports = [
  ];

  options.ca.sway = {
    enable = lib.mkEnableOption "Generate Sway configuration";
  };

  config = let
    modifier = "Mod4";
    shotman = "${pkgs.shotman.out}/bin/shotman";
  in {
    home.sessionVariables = {
      XKB_DEFAULT_LAYOUT="de,de,gr";
      XKB_DEFAULT_MODEL="pc105";
      XKB_DEFAULT_VARIANT="neo,,";
      XKB_DEFAULT_OPTIONS=",,";
      NIXOS_OZONE_WL=1;
      WLR_RENDERER="vulkan";
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
    home.packages = with pkgs; [
      alacritty
      grim
      wl-clipboard
      mako
      wayland
      xdg-utils
    ];
  };

}

