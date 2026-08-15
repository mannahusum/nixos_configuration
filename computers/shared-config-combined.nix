{
  pkgs,
  ...
}: {
  imports = [
  ];

  config = {
    nix = {
      settings = {
        keep-outputs = true;
        keep-derivations = true;
        experimental-features = "nix-command flakes";
        substituters = [
          "https://nix-community.cachix.org"
        ];
        trusted-public-keys = [
          "mannahusum.catbertsen.de:vzQcMgkUCDNjjLkZmSAlpzi9c0qZQEc/hoYz2Qb+PrY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "ulpia.catbertsen.de-1:kk+3H0S5sKZB1zD93xh6adWxtJ+CgV6mvd+Dw227hpQ="
        ];
      };
    };
    time.timeZone = "Europe/Berlin";
    programs = {
      direnv = {
        enable = true;
      };
      nix-index = {
        enable = true;
      };
    };

    environment.systemPackages = with pkgs; [
      file
      git
      git-crypt
      neovim
      ripgrep
      tpm2-tss
      xterm # for resize command
    ];
  };
}
