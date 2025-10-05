{
  config,
  lib,
  system,
  stdenvNoCC,
  ...
}: let
  cfg = config.cakeyboard;
in ({
  options.cakeyboard = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to set keyboard for Christian
      '';
    };
  };
} // (if lib.strings.hasSuffix "-linux" system then {
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
    services.xserver.xkb = {
      layout = "de,de,gr";
      model = "pc105";
      variant = "neo,,";
      options = ",,";
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
} else {
  imports = [];
  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [
      (self: super: {
        neolayout = stdenvNoCC;
      })
    ];
  };
}))
