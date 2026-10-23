{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.gigabyte_heating;
in {
  imports = [
  ];

  options.gigabyte_heating = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether there are domains to request a certificate for
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # Ensure the ryzenadj package is installed on the system
    environment.systemPackages = [ pkgs.ryzenadj ];

    # Create a declarative systemd service to apply constraints on startup
    systemd.services.ryzen-thermal-cap = {
      description = "Apply strict temperature and power caps to Ryzen 4800U Build System";
      wantedBy = [ "multi-user.target" ];
      after = [ "systemd-modules-load.service" ];
      
      # Ryzenadj requires root privileges to write to CPU registers
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = ''
          ${pkgs.ryzenadj}/bin/ryzenadj \
            --tctl-temp=80 \
            --stapm-limit=15000 \
            --fast-limit=20000 \
            --slow-limit=15000
        '';
      };
    };
  };
}
