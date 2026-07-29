{ pkgs, ... }:
{
  programs.neovim = {

    extraPackages = with pkgs; [
    ];

    plugins = with pkgs.vimPlugins; [
      vim-unimpaired
      vim-surround
      vim-repeat
      vim-commentary
      vim-eunuch
      SudoEdit-vim
      vim-vinegar
      vim-easy-align
    ];
  };
}

