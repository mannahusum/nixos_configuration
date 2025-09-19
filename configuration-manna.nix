# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./computers/mannahusum/configuration.nix
    ./configuration-gui.nix
    # ./netboot.nix
  ];

  nixpkgs.overlays = [
    (_: prev: {
      prev.linuxPackagesFor = kernel:
        (prev.linuxPackagesFor kernel).extend (_: _: {ati_drivers_x11 = null;});
    })
  ];
}
