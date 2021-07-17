{ pkgs, users, nix, services, security, programs, ... }:
{
  imports =
    [
      ./users/christian/console.nix
    ];

  nix = {
    trustedUsers = [ "root" "christian" ];
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';
  };
  users.mutableUsers = true;
  users.users.marianne.isNormalUser = true;
  programs.gnupg.agent.enable = true;

}
