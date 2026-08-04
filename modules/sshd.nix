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

  config = lib.mkIf cfg.enable (lib.mkMerge [
    (lib.mkIf (lib.strings.hasSuffix "-linux" pkgs.stdenv.hostPlatform.system)
      {
        programs.ssh = {
          setXAuthLocation = true;
          enableAskPassword = true;
        };

        services.openssh = {
          enable = true;
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
      })
    (lib.mkIf (lib.strings.hasSuffix "-darwin" pkgs.stdenv.hostPlatform.system)
      {
        services.openssh = {
          enable = true;
        };
        environment.systemPackages = with pkgs; [
          ssh_askpass
        ];
        programs.ssh.extraConfig = ''
          XAuthLocation ${pkgs.xorg.xauth}/bin/xauth
        '';
      })
  ]);
}
