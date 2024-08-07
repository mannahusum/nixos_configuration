{
  config,
  pkgs,
  ssh-keys,
  ...
}: {
  imports = [
    ./bashprofile.nix
    ./cassh.nix
    #  ./cagpg.nix
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
    # ca.gpg.enable = true;
    # ca.gpg.withExtraSocket = true;
    # ca.gpg.forwardTo = "";
    neovim.enable = true;
    pass.enable = true;
  };

  home = {
    file.ssh-keys.source = ssh-keys.packages."x86_64-linux".ssh_public_keys.out;
    packages = with pkgs; [
      home-manager
      ripgrep
      yubikey-manager
    ];
  };

  home.stateVersion = "24.05";
}
