{
  config,
  lib,
  ...
}: let
  cfg = config.casshd;
in {
  imports = [
  ];

  options.casshd = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to enable the standard sshd config
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    programs.ssh = {
      setXAuthLocation = true;
    };

    services.openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        X11Forwarding = true;
        PasswordAuthentication = false;
        # PermitRootLogin = lib.mkDefault false;
        KbdInteractiveAuthentication = false;
        GatewayPorts = "yes";
      };
    };
  };
}
