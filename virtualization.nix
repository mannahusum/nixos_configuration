{ virtualisation, users, nixpkgs, pkgs, ... }:
{
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
      enable = true;
      onBoot = "start";
      onShutdown = "suspend";
    };
    lxd = {
      enable = true;
      recommendedSysctlSettings = true;
      zfsSupport = true;
    };
  };
  systemd.services.lxd.path = with pkgs; [ (callPackage ./pkgs/nvidia-docker-new {}) ];
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
}

