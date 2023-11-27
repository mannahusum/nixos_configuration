{ config, lib, pkgs, ... }:
let
  cfg = config.cakeyboard;
in
{
  imports = [
    ./wayland.nix
  ];

  options.cakeyboard = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to set keyboard for Christian
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.xserver = {
      layout = "de,de,gr";
      xkbModel = "pc105";
      xkbVariant = "neo,,";
      xkbOptions = ",,";
    };
    console.useXkbConfig = true;
    cawayland.keyboardSettings = ''
      XKB_DEFAULT_LAYOUT="de,de,gr"
      XKB_DEFAULT_MODEL="pc105"
      XKB_DEFAULT_VARIANT="neo,,"
      XKB_DEFAULT_OPTIONS=",,"
      export XKB_DEFAULT_LAYOUT XKB_DEFAULT_MODEL XKB_DEFAULT_VARIANT XKB_DEFAULT_OPTIONS
    '';
  };
}

