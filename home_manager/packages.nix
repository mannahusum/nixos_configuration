{
  pkgs,
  ...
}: {
  home = {
    packages = with pkgs; [
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
}

