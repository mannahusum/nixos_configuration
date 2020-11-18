{ pkgs, users, nix, services, security, programs, ... }:
{
  imports =
    [
      ./users/christian/console.nix
      ./users/marianne/console.nix
    ];

  nix = {
    trustedUsers = [ "root" "christian" "marianne" ];
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';
  };
  users.mutableUsers = true;

}
