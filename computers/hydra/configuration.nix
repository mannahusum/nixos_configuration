({ modulesPath, lib, ssh-keys, boot, pkgs, ... }: {
  imports = [
    (modulesPath + "/profiles/base.nix")
    ../../modules/system_administration/debug.nix
    ../../modules/users.nix
  ];
  disko.devices = import ./disko-config.nix {
    inherit lib;
  };
  boot.supportedFilesystems = [ "zfs" ];
  boot.loader.efi = {
    # canTouchEfiVariables = true;
    efiSysMountPoint = "/boot";
  };
  boot.initrd.supportedFilesystems = [ "zfs" ];
  boot.initrd.systemd = {
    enable = true;
    emergencyAccess = true;
  };
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 10;
    graceful = true;
  };
  boot.kernelParams = [
    "console=ttyS0,115200"
  ];
  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
    experimental-features = nix-command flakes
  '';
  nix.settings = {
    substituters = [
      "http://mannahusum.catbertsen.de:5000/"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "mannahusum.catbertsen.de:vzQcMgkUCDNjjLkZmSAlpzi9c0qZQEc/hoYz2Qb+PrY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
  services.openssh.enable = true;

  networking.hostId = "d22d38ba";
  networking.hostName = "hydra";
  networking.hosts = {
    "192.168.10.253" = [ "mannahusum.catbertsen.de" ];
    "192.168.10.254" = [ "hydra.catbertsen.de" ];
  };

  environment.systemPackages = [
    pkgs.git
  ];
  system.stateVersion = "23.05";
})
