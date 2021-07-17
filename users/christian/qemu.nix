{ lib, pkgs, home, config, nixpkgs,
  makeWrapper, gobject-introspection, cmake,
  python3Packages, gtk3, glib, libnotify, intltool, gnome3,
  gdk-pixbuf, librsvg,
  ... }:

let
  profileDirectory = config.home.profileDirectory;
in let
  profiles = [
    "/nix/var/nix/profiles/default" profileDirectory ];
  dataDirs = lib.concatStringsSep ":"
    (map (profile: "${profile}/share") profiles
    ++ config.targets.genericLinux.extraXdgDataDirs);
  myOVMF = ( pkgs.OVMF.override { seabios = true; });
  
in {
  # nixpkgs.overlays = [
  #   (self: super: {
  #       gcdemu = import /etc/nixos/pkgs/cdemu/gui.nix {
  #         inherit makeWrapper gobject-introspection cmake
  #                 python3Packages glib libnotify intltool gnome3
  #                 gdk-pixbuf librsvg gtk3;
  #         callPackage = lib.callPackage;
  #       };
  #     }
  #   )
  # ];

  home.packages = with pkgs; [
    qemu
    vde2
    smbclient
    myOVMF
  ];

  home.sessionVariables = {
    QEMU_NET_OPTS="type=vde,sock=$XDG_RUNTIME_DIR/vde_ctl";
    OVMF="${myOVMF.fd}";
  };

  systemd.user.services.vde2 = {
    Unit = {
      Description = "Virtual Network Switch";
      After="syslog.target";
    };
    Install = { WantedBy = [ "default.target" ]; };
    Service = {
      Type = "forking";
      RuntimeDirectory="vde_ctl";
      RuntimeDirectoryMode="750";
      ExecStart = "${pkgs.vde2.out}/bin/vde_switch -tap catap0 --mode 660 --dirmode 750 --daemon -sock $RUNTIME_DIRECTORY";
      Restart = "on-failure";
    };
  };

  # Work around the missing path to the daemon in the dbus activation script
  home.file.".cdemu-daemon" = {
    text = ''
CDEMU_PATH=''${BASH_SOURCE[1]}
PATH="''${PATH}:''${CDEMU_PATH%libexec*}/bin"
LOG_FILE=/tmp/cdemu-daemon.log
AUDIO_DRIVER=pulse
    '';
  };

  systemd.user.services.gcdemu = {
    Unit = {
      Description = "CD Emulation Applet";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Install = { WantedBy = [ "graphical-session.target" ]; };
    Service = {
      # Environment="GDK_PIXBUF_MODULE_FILE=${config.environment.variables.GDK_PIXBUF_MODULE_FILE}";
      Type = "simple";
      ExecStart = "${pkgs.gcdemu.out}/bin/gcdemu";
      Restart = "on-failure";
    };
  };
}
