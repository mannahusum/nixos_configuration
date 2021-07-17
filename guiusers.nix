{ pkgs, users, nix, services, security, programs, ... }:
{
  imports =
    [
      ./users.nix
      ./users/christian/gui.nix
    ];

  networking.firewall = {
    # 8512 Mnemosyne Sync
    # 9090 Calibre Sync
    allowedTCPPorts = [
      8512
      9090
    ];
  };

  # services.gnome.gnome-keyring.enable = true;
  # security.pam.services.login = {
  #   enableGnomeKeyring = true;
  # };
  programs.seahorse.enable = true;
}
