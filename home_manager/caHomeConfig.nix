{
  nixpkgs,
  system,
  forwardTo ? null,
  createForwardPath ? false,
  withExtraSocket ? false,
  ...
}: let
  mypkgs = import nixpkgs {
    inherit system;
    config.allowUnfreePredicate = pkg:
      builtins.elem (nixpkgs.lib.getName pkg) [
        "google-chrome"
      ];
    overlays = [
      (import ../packages/ssh/overlay.nix)
    ];
    check = false;
  };
in {
  imports = [
    ./bashprofile.nix
    ./cagpg.nix
    ./cassh.nix
    ./chrome.nix
    ./neovim.nix
    ./passwordstore.nix
    ./sway.nix
  ];

  nixpkgs = {
    inherit system;
    config.allowUnfreePredicate = pkg:
      builtins.elem (nixpkgs.lib.getName pkg) [
        "google-chrome"
      ];
    overlays = [
      (import ../packages/ssh/overlay.nix)
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

  home = {
    # file.ssh-keys.source = mypkgs.al_public_keyfile;
    packages = with mypkgs; [
      file
      fzf
      home-manager
      pandoc
      pdftk
      psmisc
      qrcode
      ranger
      ripgrep
      tldr
      units
      wipe
      yubikey-manager
    ];
  };

  home.stateVersion = "24.11";
}
