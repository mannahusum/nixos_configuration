{
  createForwardPath ? false,
  forwardTo ? null,
  nixpkgs,
  overlays,
  system,
  withExtraSocket ? false,
  ...
}: {
  imports = [
    ./bashprofile.nix
    ./cagpg.nix
    ./cassh.nix
    ./chrome.nix
    ./neovim.nix
    ./packages.nix
    ./passwordstore.nix
    ./sway.nix
  ];

  nixpkgs = {
    inherit overlays system;
    config.allowUnfreePredicate = pkg:
      builtins.elem (nixpkgs.lib.getName pkg) [
        "google-chrome"
      ];
  };

  ca = {
    bash.enable = true;
    chrome.enable = true;
    ssh = {
      enable = true;
    };
    gpg = {
      inherit forwardTo createForwardPath withExtraSocket;
      enable = true;
    };
    neovim = {
      enable = true;
      backgroundservice = true;
    };
    pass.enable = true;
  };

  home.stateVersion = "24.11";
}
