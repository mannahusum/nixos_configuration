{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.cakeyboard;
  linux = lib.strings.hasSuffix "-linux" pkgs.stdenv.hostPlatform.system;
  darwin = lib.strings.hasSuffix "-darwin" pkgs.stdenv.hostPlatform.system;
in {
  options.cakeyboard = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to set keyboard for Christian
      '';
    };
  };
  imports = [
    ./wayland.nix
  ];
  config = lib.mkIf cfg.enable (lib.mkMerge [
    (lib.mkIf linux {
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
    })
    (lib.mkIf darwin {
      # Basic installation of Neo Layout
      system.systemBuilderCommands = ''
        mkdir -p "''${out}/Library/Keyboard Layouts"
        ln -s ${pkgs.neolayout.out}/neo-layouts.bundle "''${out}/Library/Keyboard Layouts"
      '';
      system.activationScripts.preActivation.text = ''
        printf >&2 'setting up /Library/Keyboard Layouts/neo-layouts.bundle...\n'

        ${pkgs.rsync}/bin/rsync \
          --archive \
          --copy-links \
          --delete-during \
          --delete-missing-args \
          "$systemConfig/Library/Keyboard Layouts/neo-layouts.bundle" \
          '/Library/Keyboard Layouts/'
      '';

      # Karabiner-Elements for other layers
      # Can currently not be enabled in stable nixpkgs, since darwin expects older elements
      # services.karabiner-elements = {
      #   enable = true;
      # };
    })
  ]);
}
