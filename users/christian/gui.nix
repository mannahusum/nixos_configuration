{ pkgs, users, nix, services, security, programs, ... }:
{
  imports =
    [
      ./console.nix
    ];


  users.users.christian = {
    packages = with pkgs; [
      awesome
      vimHugeX
      xterm
    ];
  };
}
