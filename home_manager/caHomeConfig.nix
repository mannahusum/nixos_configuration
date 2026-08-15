{
  createForwardPath ? false,
  forwardTo ? null,
  nixpkgs,
  overlays,
  pinentry,
  system_type,
  withExtraSocket ? false,
  filebotLicense ? null,
  ...
}: ({
  imports = [
    ./bashprofile.nix
    ./cagit.nix
    ./cagpg.nix
    ./cassh.nix
    ./chrome.nix
    ./filebot.nix
    ./neovim.nix
    ./packages.nix
    ./passwordstore.nix
    ./sway.nix
  ];

  nixpkgs = {
    inherit overlays;
    system = system_type;
    config.allowUnfreePredicate = pkg:
      builtins.elem (nixpkgs.lib.getName pkg) [
        "google-chrome"
        "makemkv"
        "unrar"
      ];
  };

  ca = {
    bash.enable = true;
    chrome.enable = true;
    filebot.license = filebotLicense;
    git.enable = true;
    gpg = {
      inherit forwardTo createForwardPath pinentry withExtraSocket;
      enable = true;
    };
    neovim = {
      enable = true;
      backgroundservice = true;
    };
    pass.enable = true;
    ssh = {
      enable = true;
    };
  };
})
