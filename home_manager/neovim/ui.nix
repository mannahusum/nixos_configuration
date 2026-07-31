{ pkgs, ... }:
{
  imports = [
    ./treesitter.nix
  ];

  programs.neovim = {

    extraPackages = with pkgs; [
      trash-cli
      kitty
      imagemagick
      ghostscript
      mermaid-cli
      lazygit
      fd
      sqlite
    ];

    extraLuaPackages = ps: with ps; [
      ljsyscall
    ];

    plugins = with pkgs.vimPlugins; [
      vim-airline-themes
      {
        type = "lua";
        plugin = snacks-nvim;
        config = ''
          require("snacks").setup({
            registers = { enabled = true, },
            notifier = { enabled = true, },
            input = { enabled = true },
            picker = { enabled = true },
          })
        '';
      }
      {
        type = "viml";
        plugin = vim-airline;
        config = ''
          set laststatus=2 " Always display statusline in all windows
          set ambiwidth=single " needed for powerfonts

          let g:airline_powerline_fonts = 1
          let g:airline_detect_modified = 1
          let g:airline_detect_paste = 1

          " Extensions
          let g:airline#extensions#virtualenv#enabled = 1
          let g:airline#extensions#coc#enabled = 1

          " Whitespace warnings
          let g:airline#extensions#whitespace#enabled = 1
          let g:airline#extensions#whitespace#checks = [
            \ 'indent',
            \ 'trailing',
            \ 'long',
            \ 'mixed-indent-file',
            \ ]

          " Titles for special buffers
          let g:airline#extensions#quickfix#quickfix_text = 'Quickfix'
          let g:airline#extensions#quickfix#location_text = 'Location'

          " Fugitive integration
          let g:airline#extensions#branch#enabled = 1
          let g:airline#extensions#branch#format = 2
        '';
      }
      vim-signify
      {
        type = "viml";
        plugin = solarized-nvim;
        config = ''
          colorscheme solarized
        '';
      }
      fidget-nvim

      markdown-preview-nvim
    ];
  };
}
