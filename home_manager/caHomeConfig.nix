{
  config,
  pkgs,
  publickeys,
  ...
}: {
  imports = [
    #  ./bashprofile.nix
    #  ./cassh.nix
    #  ./cagpg.nix
    ./neovim.nix
    ./passwordstore.nix
    ./sway.nix
  ];

  ca = {
    bash.enable = true;
    ssh = {
      enable = true;
      publicKeys = publickeys;
    };
    # ca.ssh.publicKeys = pkgs.lib.strings.splitString "\n" (builtins.readFile ''${publickeys}'');
    # ca.gpg.enable = true;
    # ca.gpg.withExtraSocket = true;
    # ca.gpg.forwardTo = "";
    neovim.enable = true;
    pass.enable = true;
  };

  home = {
    file.ssh-keys.source = publickeys;
    packages = with pkgs; [
      home-manager
      ripgrep
      yubikey-manager
    ];
  };

  home.stateVersion = "24.05";
}
