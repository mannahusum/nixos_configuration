{pkgs, ...}: {
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      SudoEdit-vim
      {
        type = "viml";
        plugin = open-browser-vim;
        config = ''
          nmap <localleader>o <Plug>(openbrowser-open)
        '';
      }
      {
        type = "viml";
        plugin = pkgs.vimUtils.buildVimPlugin {
          pname = "open-browser-unicode.vim";
          version = "1.0.0";
          src = pkgs.fetchFromGitHub {
            owner = "tyru";
            repo = "open-browser-unicode.vim";
            rev = "ceeef2e5f641ae49668dfc0e528b4a2a96dcfb5e";
            hash = "sha256-MrcoQfeMATiJzO74V1xZhKezU6nMIE+8ubFfYIpKx2A=";
          };
        };
        config = ''
          nmap <localleader>U :OpenBrowserUnicode<cr>
        '';
      }
      telescope-fzf-native-nvim
      {
        type = "viml";
        plugin = telescope-nvim;
        config = ''
          nnoremap <localleader>Tf <cmd>Telescope find_files<cr>
          nnoremap <localleader>TG <cmd>Telescope live_grep<cr>
          nnoremap <localleader>Tg <cmd>Telescope git_files<cr>
          nnoremap <localleader>Tb <cmd>Telescope buffers<cr>
          nnoremap <localleader>Th <cmd>Telescope help_tags<cr>
          nnoremap <localleader>To <cmd>Telescope oldfiles<cr>
        '';
      }
      {
        type = "viml";
        plugin = vimtex;
        config = ''
          let g:tex_flavor = "latex"
        '';
      }
      vim-commentary
      {
        type = "viml";
        plugin = vim-easy-align;
        config = ''
          xmap <localleader>a <Plug>(EasyAlign)
          nmap <localleader>a <Plug>(EasyAlign)
        '';
      }
      vim-eunuch
      vim-indent-object
      vim-repeat
      {
        type = "viml";
        plugin = vim-surround;
        config = ''
          let b:surround_{char2nr('e')}
              \ = "\\begin{\1environment: \1}\n\t\r\n\\end{\1\1}"
          let b:surround_{char2nr('c')} = "\\\1command: \1{\r}"
        '';
      }
      vim-unimpaired
      vim-vinegar
    ];
  };
}
