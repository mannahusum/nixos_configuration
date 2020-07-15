{ pkgs, users, nix, ... }:
{
  nix.trustedUsers = [ "root" "christian" ];
  users.mutableUsers = true;
  users.users.christian = {
    createHome = true;
    description = "Christian Albertsen";
    extraGroups = [
      "camera"
      "docker"
      "lxd"
      "render"
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
      awesome
      bashInteractive
      coreutils-full
      file
      git
      glxinfo
      google-chrome
      neomutt
      khard
      lutris
      mnemosyne
      mlterm
      mplayer
      mu
      nerdfonts
      nodejs
      notmuch
      notmuch-mutt
      offlineimap
      pavucontrol
      pwsafe
      ranger
      ripgrep
      steam
      sxiv
      unzip
      usbutils vimHugeX
      xorg.xdpyinfo
      zathura
    ];
  };
}
