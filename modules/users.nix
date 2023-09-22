{ config, pkgs, lib, modulesPath, ssh-keys, ... }: {
  imports = [
    # Paths to other modules.
    # Compose this module out of smaller ones.
  ];

  options = {
    # Option declarations.
    # Declare what settings a user of this module module can set.
    # Usually this includes an "enable" option to let a user of this module choose.
  };

  config = {
    # Option definitions.
    # Define what other settings, services and resources should be active.
    # Usually these are depend on whether a user of this module chose to "enable" it
    # using the "option" above.
    # You also set options here for modules that you imported in "imports".
    users.users.christian = {
      createHome = true;
      description = "Christian Albertsen";
      extraGroups = [
        "camera"
        "cdrom"
        "dialout"
        "disk"
        "docker"
        "kvm"
        "libvirtd"
        "lp"
        "lxd"
        "qemu-libvirtd"
        "render"
        "scanner"
        "transmission"
        "video"
        "vboxusers"
        "wheel"
        "networkmanager"
      ]; # Enable ‘sudo’ for the user.
      home = "/home/christian";
      isNormalUser = true;
      uid = 1005;
      subUidRanges = [
        {
          count = 65536;
          startUid = 65536;
        }
      ];
      subGidRanges = [
        {
          count = 65536;
          startGid = 65536;
        }
      ];
      packages = with pkgs; [
        dash
        coreutils-full
      ];
      openssh.authorizedKeys.keyFiles = [
        # The keys are the same for any system type
        ssh-keys.packages."x86_64-linux".ssh_public_keys.out
      ];
    };
    nix.settings.trusted-users = [ "root" "christian" ];
    users.mutableUsers = true;
    # users.users.marianne.isNormalUser = true;
    programs.gnupg.agent.enable = true;
  };
}
