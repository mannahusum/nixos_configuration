{
  config,
  lib,
  nixpkgs,
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
          ...
        }: {
          imports = [
            (modulesPath + "/installer/netboot/netboot-minimal.nix")
          ];
          config = {
            ## Some useful options for setting up a new system
            # services.getty.autologinUser = lib.mkForce "root";
            # users.users.root.openssh.authorizedKeys.keys = [ ... ];
            # console.keyMap = "de";
            # hardware.video.hidpi.enable = true;

            system.stateVersion = config.system.nixos.release;
          };
        })
      ];
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
