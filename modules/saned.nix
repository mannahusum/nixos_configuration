{
  config,
  lib,
  nixpkgs-utsushi,
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

  config = lib.mkIf cfg.enable {
    services.udev.packages = [nixpkgs-utsushi.legacyPackages.x86_64-linux.utsushi];
    hardware.sane = {
      enable = true;
      extraBackends = [nixpkgs-utsushi.legacyPackages.x86_64-linux.utsushi];
      openFirewall = true;
    };
    services.saned.enable = true;
    causers.regularUserGroups = ["lp" "scanner"];
  };
}
