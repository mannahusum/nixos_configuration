{
  createForwardPath ? false,
  desktop ? true,
  filebotLicense ? null,
  forwardTo ? null,
  nixpkgs,
  overlays,
  pinentry,
  system_type,
  withExtraSocket ? false,
  ui ? true,
  ...
}: {
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
    chrome.enable = ui;
    filebot.license = filebotLicense;
    git.enable = true;
    gpg = {
      inherit forwardTo createForwardPath pinentry withExtraSocket;
      enable = true;
    };
    neovim = {
      inherit desktop;
      enable = true;
      backgroundservice = false;
    };
    packages = {
      inherit desktop;
      enable = true;
    };
    pass.enable = true;
    ssh.enable = true;
    sway.enable = ui;
  };
}
