{
  config,
  lib,
  pkgs,
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
    programs.ssh = (lib.optionalAttrs (pkgs.stdenv.hostPlatform.isLinux) {
      setXAuthLocation = true;
      enableAskPassword = true;
    }) //
    (lib.optionalAttrs (pkgs.stdenv.hostPlatform.isDarwin) {
      extraConfig = ''
        XAuthLocation ${pkgs.xauth}/bin/xauth
      '';
    });
    services = {
      openssh.enable = true;
    } // lib.optionalAttrs (pkgs.stdenv.hostPlatform.isLinux) {
      openssh = {
        openFirewall = true;
        settings = {
          X11Forwarding = true;
          PasswordAuthentication = false;
          PermitRootLogin = lib.mkDefault "no";
          KbdInteractiveAuthentication = false;
          GatewayPorts = "yes";
          StreamLocalBindUnlink = "yes";
        };
      };
    };
    environment.systemPackages = lib.optional (pkgs.stdenv.hostPlatform.isDarwin) pkgs.ssh_askpass;
  };
}
