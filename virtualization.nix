{
  virtualisation,
  users,
  pkgs,
  environment,
  ...
}: {
  virtualisation = {
    docker = {
      autoPrune = {
        dates = "weekly";
        enable = true;
      };
      enable = true;
      enableNvidia = true;
      enableOnBoot = true;
      listenOptions = [
        "[::]:2375"
        "/run/docker.sock"
        # "0.0.0.0:2375"
      ];
      storageDriver = "zfs";
    };
    libvirtd = {
      allowedBridges = [
        "virbr0"
        "fi0"
      ];
      qemu = {
        swtpm = {
          enable = true;
        };
        ovmf = {
          enable = true;
          packages = [pkgs.OVMFFull];
        };
        package = pkgs.qemu_kvm;
      };
      enable = true;
      onBoot = "start";
      onShutdown = "suspend";
    };
    # virtualbox.host = {
    #   enable = true;
    # };
    lxd = {
      enable = true;
      recommendedSysctlSettings = true;
      zfsSupport = true;
    };
    lxc.lxcfs.enable = true;
  };

  environment = {
    sessionVariables = {
      LIBVIRT_DEFAULT_URI = "qemu:///system";
      VAGRANT_DEFAULT_PROVIDER = "libvirt";
    };
    systemPackages = with pkgs; [
      virt-manager
      win-virtio
      virt-viewer
    ];
  };

  # systemd.services.lxd.path = with pkgs; [ (callPackage ./pkgs/nvidia-docker-new {}) ];
  users.extraUsers.root = {
    subUidRanges = [
      {
        startUid = 1000000;
        count = 1048576;
      }
    ];
    subGidRanges = [
      {
        startGid = 1000000;
        count = 1048576;
      }
    ];
  };

  networking.firewall = {
    allowedTCPPorts = [
      137
      138
      139
      445
    ];
    allowedUDPPorts = [
      137
      138
      139
      445
    ];
  };

  # services.pixiecore = {
  #   port = 7780;
  #   mode = "boot";
  #   debug = true;
  #   listen = "10.42.0.1";
  #   kernel = "/nix/store/428cixy93z74m8r6gw0g7rlgp68zz2l0-linux-5.4.108/bzImage";
  #   initrd = "/nix/store/0p4p1r7cf8aml07ncgjny9k8jxilh2as-initrd/initrd";
  #   cmdLine = "init=/nix/store/h34rx8ys65603nj9jd8gdbxrjb3vd9j7-extra-utils/bin/init initrd=initrd loglevel=4 console=ttyS0";
  #   enable = true;
  #   statusPort = 7780;
  #   dhcpNoBind = true;
  #   openFirewall = true;
  # };
  #services.samba = {
  #  enable = true;
  #  securityType = "user";
  #  package = pkgs.samba4Full;
  #  extraConfig = ''
  #    workgroup = WORKGROUP
  #    netbios name = smbnix
  #    server string = smbnix
  #    security = user
  #    passdb backend = tdbsam
  #    # encrypt passwords = yes
  #    ntlm auth = ntlmv1-permitted
  #    lanman auth = Yes
  #    server min protocol = LANMAN1
  #    client lanman auth = Yes
  #    client plaintext auth = Yes
  #    client ntlmv2 auth = No
  #    client min protocol = LANMAN1
  #    # client max protocol = SBM3
  #    server signing = disabled
  #    #use sendfile = yes
  #    #max protocol = smb2
  #    hosts allow = 10.42.0.0/16  localhost
  #    hosts deny = 0.0.0.0/0
  #    guest account = nobody
  #    map to guest = bad user
  #    load printers = yes
  #    printcap name = cups
  #  '';
  #  shares = {
  #    printers = {
  #      comment = "All Printers";
  #      path = "/var/spool/samba";
  #      public = "yes";
  #      browseable = "yes";
  #      # to allow user 'guest account' to print.
  #      "guest ok" = "yes";
  #      writable = "no";
  #      printable = "yes";
  #      "create mode" = 0700;
  #      printing = "CUPS";
  #    };
  #    public = {
  #      path = "/home/christian/Projekte/WindowsVista";
  #      browseable = "yes";
  #      "read only" = "no";
  #      "guest ok" = "yes";
  #      "create mask" = "0644";
  #      "directory mask" = "0755";
  #      "force user" = "christian";
  #      "force group" = "users";
  #    };
  #    # private = {
  #    #   path = "/mnt/Shares/Private";
  #    #   browseable = "yes";
  #    #   "read only" = "no";
  #    #   "guest ok" = "no";
  #    #   "create mask" = "0644";
  #    #   "directory mask" = "0755";
  #    #   "force user" = "username";
  #    #   "force group" = "groupname";
  #    # };
  #  };
  #};

  boot.extraModprobeConfig = ''
    options kvm_intel nested=1
    options kvm_intel emulate_invalid_guest_state=0
    options kvm ignore_msrs=1
  '';

  # systemd.tmpfiles.rules = [
  #   "d /var/spool/samba 1777 root root -"
  # ];
}
