{ pkgs, users, nix, services, security, programs, ... }:

let

  nixpkgs = {
    url = "https://github.com/NixOS/nixpkgs/";
    ref = "nixos-20.09";
    rev = "f8929dce13e729357f31d5b2950cbb097744bed7";
  };

  home-manager = builtins.fetchGit {
    url = "https://github.com/nix-community/home-manager.git";
    rev = "209566c752c4428c7692c134731971193f06b37c";
    ref = "release-20.09";
  };

in {

  # imports = [
  #     (import "${home-manager}/nixos")
  # ];

  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.0.2u"
  ];

  # home-manager.users.christian = import ./home.nix;
  # home-manager.useUserPackages = true;
  # home-manager.useGlobalPkgs = true;
  # home-manager.users.christian = ./home.nix;

  users.users.christian = {
    createHome = true;
    description = "Christian Albertsen";
    extraGroups = [
      "camera"
      "cdrom"
      "dialout"
      "disk"
      "docker"
      "libvirtd"
      "lp"
      "lxd"
      "render"
      "scanner"
      "transmission"
      "video"
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
  };
}
