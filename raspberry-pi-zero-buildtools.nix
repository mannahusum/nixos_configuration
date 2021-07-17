{ boot, ... }:
{
  boot.binfmt.emulatedSystems = [
    "armv6l-linux"
    "aarch64-linux"
    "armv7l-linux"
  ];
}
