{ pkgs, users, nix, services, security, programs, ... }:
{
  imports =
    [
      ./users.nix
      ./users/christian/gui.nix
      ./users/marianne/gui.nix
    ];

  networking.firewall = {
    allowedTCPPorts = [ 8512 ]; # for Mnemosyne Sync
  };

  services.gnome3.gnome-keyring.enable = true;
  security.pam.services.lightdm = {
    enableGnomeKeyring = true;
  };
  programs.seahorse.enable = true;
}
