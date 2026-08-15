{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.cakeyboard;
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
  ];
  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      environment.systemPackages = with pkgs; [
        bash
      ];
    }
    (lib.mkIf pkgs.stdenv.isDarwin {
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
    })]);
}
