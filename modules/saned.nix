{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.casaned;
  linux = lib.strings.hasSuffix "-linux" pkgs.stdenv.hostPlatform.system;
  darwin = lib.strings.hasSuffix "-darwin" pkgs.stdenv.hostPlatform.system;
in {
  imports = [
    ./users.nix
  ];

  options.casaned = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether there should be a saned running on this computer in order to make a scanner accessible to the network
      '';
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.enable && linux) {
      hardware.sane = {
        enable = true;
        openFirewall = true;
      };
      services.saned.enable = true;
      causers.regularUserGroups = ["lp" "scanner"];
    })
    (lib.mkIf (cfg.enable && darwin) {
      environment.systemPackages = with pkgs; [
        epsonscan2
      ];
    })
  ];
}
