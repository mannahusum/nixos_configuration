({
  # lib,
  pkgs,
  ...
}: {
  boot.initrd.systemd.emergencyAccess = true;
  # services.getty.autologinUser = lib.mkForce "root";
  users.users.root.openssh.authorizedKeys.keys = pkgs.al_public_keys;
})
