{
  config,
  lib,
  pkgs,
  system,
  ...
}: let
  cfg = config.casaned;
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

  config =
    lib.mkIf cfg.enable {
    }
    // (
      if lib.strings.hasSuffix "-linux" system
      then {
        hardware.sane = {
          enable = true;
          openFirewall = true;
        };
        services.saned.enable = true;
        causers.regularUserGroups = ["lp" "scanner"];
      }
      else if lib.strings.hasSuffix "-darwin" system
      then {
        environment.systemPackages = with pkgs; [
          epsonscan2
        ];
      }
      else {}
    );
}
