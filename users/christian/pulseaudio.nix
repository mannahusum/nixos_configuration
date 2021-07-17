{ pkgs, systemd, services, ...}:
{
  systemd.user.sockets.pulseaudio = {
    Unit = {
      Description = "Pulseaudio Sound System";
    };
    Socket = {
      RuntimeDirectory = "pulse";
      RuntimeDirectoryMode = "700";
      Priority = 6;
      Backlog = 5;
      ListenStream = "%t/pulse/native";
    };
  };
  systemd.user.services.pulseaudio = {
    Unit = {
      Description = "Pulseaudio Sound System";
      Requires = "dbus.socket";
    };
    Service = {
      Type = "notify";
      ExecStart = "${pkgs.pulseaudio.out}/bin/pulseaudio --verbose --daemonize=no";
      Restart = "on-failure";
    };
    Install = {
      Also = "pulseaudio.socket";
    };
  };
  services.pasystray.enable = true;
}
