{
  config,
  lib,
  nixpkgs,
  home-manager,
  nixos-luks-yk,
  nixpkgs-utsushi,
  overlays,
  sops-nix,
  ...
}: let
  cfg = config.capixiecore;
in {
  imports = [];

  options.capixiecore = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether giteo should be running on this server
      '';
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 64172;
      example = 65533;
      description = ''
        status-port used by pixiecore
      '';
    };
    statusPort = lib.mkOption {
      type = lib.types.port;
      default = 64172;
      example = 65533;
      description = ''
        status-port used by pixiecore
      '';
    };
  };

  config = let
    sys = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({
          config,
          pkgs,
          lib,
          modulesPath,
          overlays,
          ...
        }: {
          imports = [
            (modulesPath + "/installer/netboot/netboot-minimal.nix")
            ./users.nix
          ];
          config = {
            nixpkgs = {
              inherit overlays;
              config.allowUnfreePredicate = pkg:
                builtins.elem (lib.getName pkg) [
                  "google-chrome"
                ];
            };

            system.stateVersion = config.system.nixos.release;
          };
        })
      ];
      specialArgs = {
        inherit home-manager nixos-luks-yk nixpkgs nixpkgs-utsushi overlays sops-nix;
        system = "x86_64-linux";
      };
    };
  in
    lib.mkIf cfg.enable {
      services.pixiecore = let
        build = sys.config.system.build;
      in {
        cmdLine = "init=${build.toplevel}/init loglevel=4";
        debug = true;
        dhcpNoBind = true;
        enable = true;
        initrd = "${build.netbootRamdisk}/initrd";
        kernel = "${build.kernel}/bzImage";
        mode = "boot";
        openFirewall = true;
        port = cfg.port;
        statusPort = cfg.statusPort;
      };
    };
}
