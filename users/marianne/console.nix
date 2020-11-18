{ pkgs, users, ... }: {
  users.users.marianne = {
    createHome = true;
    description = "Marianne Lorenzen";
    extraGroups = [
      "camera"
      "dialout"
      "docker"
      "lp"
      "lxd"
      "render"
      "scanner"
      "video"
      "wheel"
      "networkmanager"
    ]; # Enable ‘sudo’ for the user.
    home = "/home/marianne";
    isNormalUser = true;
    uid = 1020;
    packages = with pkgs; [
      bashInteractive
      coreutils-full
    ];
  };
}
