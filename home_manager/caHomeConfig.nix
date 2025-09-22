{
  config,
  nixpkgs,
  system,
  ssh-keys,
  ...
}: let
  mypkgs = import nixpkgs {
    inherit system;
    config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [
      "google-chrome"
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
   config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [
     "google-chrome"
   ];
  };
  ca = {
    bash.enable = true;
    chrome.enable = true;
    ssh = {
      enable = true;
    };
    gpg.enable = true;
    # gpg.withExtraSocket = true;
    # gpg.forwardTo = "";
    neovim = {
      enable = true;
      backgroundservice = true;
    };
    pass.enable = true;
  };

  home = {
    file.ssh-keys.source = ssh-keys.packages."${system}".ssh_public_keys.out;
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
