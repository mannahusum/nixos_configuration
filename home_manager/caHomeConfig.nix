{
  config,
  pkgs,
  ssh-keys,
  ...
}: {
  imports = [
    ./bashprofile.nix
    ./cassh.nix
    ./cagpg.nix
    ./neovim.nix
    ./passwordstore.nix
    ./sway.nix
  ];

  ca = {
    bash.enable = true;
    ssh = {
      enable = true;
      publicKeys = "${ssh-keys.packages."x86_64-linux".ssh_public_keys.out}";
    };
    gpg.enable = true;
    # gpg.withExtraSocket = true;
    # gpg.forwardTo = "";
    neovim.enable = true;
    pass.enable = true;
  };

  home = {
    file.ssh-keys.source = ssh-keys.packages."x86_64-linux".ssh_public_keys.out;
    packages = with pkgs; [
      file
      fzf
      qrcode
      home-manager
      pandoc
      pdftk
      psmisc
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
