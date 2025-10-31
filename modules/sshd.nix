{
  config,
  lib,
  pkgs,
  system,
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

  config = lib.mkIf cfg.enable ({
    services.openssh = {
      enable = true;
    };
  } // (if lib.strings.hasSuffix "-linux" system then {
    programs.ssh = {
      setXAuthLocation = true;
      enableAskPassword = true;
    };

    services.openssh = {
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
  } else if lib.strings.hasSuffix "-darwin" system then {
    environment.systemPackages = with pkgs; [
      ssh_askpass
    ];
    programs.ssh.extraConfig = ''
      XAuthLocation ${pkgs.xorg.xauth}/bin/xauth
    '';
  } else {}));
}
