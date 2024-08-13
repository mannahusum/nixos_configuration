({
  lib,
  ssh-keys,
  ...
}: {
  boot.initrd.systemd.emergencyAccess = true;
  services.getty.autologinUser = lib.mkForce "root";
  users.users.root.openssh.authorizedKeys.keyFiles = [
    # The keys are the same for any system type
    ssh-keys.packages."x86_64-linux".ssh_public_keys.out
  ];
})
