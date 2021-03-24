{ pkgs, users, nix, services, security, programs, ... }:
{
  users.users.christian = {
    createHome = true;
    description = "Christian Albertsen";
    extraGroups = [
      "camera"
      "dialout"
      "docker"
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
    # subUidRanges = [
    #   {
    #     count = 65536;
    #     startUid = 65536;
    #   }
    # ];
    # subGidRanges = [
    #   {
    #     count = 65536;
    #     startGid = 65536;
    #   }
    # ];
    packages = with pkgs; [
      dash
      coreutils-full
    ];
  };
}

