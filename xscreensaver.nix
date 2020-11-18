{ config, lib, pkgs, programs, ... }:

{
  environment.systemPackages = with pkgs; [
    xscreensaver
  ];

  networking.firewall = {
    allowedTCPPorts = [ 17500 ];
    allowedUDPPorts = [ 17500 ];
  };

  systemd.user.services.xscreensaver = {
    description = "XScreensaver";
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStartPre = "${pkgs.xscreensaver.out}/bin/xscreensaver-command -exit";
      ExecStart = "${pkgs.xscreensaver.out}/bin/xscreensaver -no-splash";
      ExecStop = "${pkgs.xscreensaver.out}/bin/xscreensaver-command -exit";
      KillMode = "control-group"; # upstream recommends process
      Restart = "on-failure";
      PrivateTmp = true;
      ProtectSystem = "full";
      Nice = 10;
    };
  };
  programs.xss-lock = {
    enable = true;
    # extraOptions = [
    #   ''--session=''${XDG_SESSION_ID}''
    # ];
    lockerCommand = "${pkgs.xscreensaver.out}/bin/xscreensaver-command --lock";
  };
}
