{pkgs, ...}: {
  programs.neovim = {
    extraPackages = with pkgs; [
      fzf
      git
      ripgrep
      fd
      bat
      viu
      chafa
      ueberzugpp
    ];

    extraLuaPackages = ps:
      with ps; [
      ];

    plugins = with pkgs.vimPlugins; [
      {
        type = "viml";
        plugin = nvim-sops;
        config = ''
          nnoremap <localleader>Sd :SopsDecrypt<CR>
          nnoremap <localleader>Se :SopsEncrypt<CR>
        '';
      }
      {
        type = "viml";
        plugin = pkgs.vimUtils.buildVimPlugin {
          pname = "simplenote.vim";
          version = "v2.4.0_8bugfixes";
          src = pkgs.fetchFromGitHub {
            owner = "simplenote-vim";
            repo = "simplenote.vim";
            rev = "3e9219992d40550c56010618478b267589219799";
            hash = "sha256-Jdifd/ME+5PME5PvSiMiZzCfGkjJu3OezgocGC/NtMA=";
            fetchSubmodules = true;
          };
        };
      }
      direnv-vim
      vim-dispatch
      vim-dispatch-neovim
      # rest-nvim
      fzf-lua
      {
        type = "lua";
        plugin = mini-icons;
        config = ''
          require('mini.icons').setup()
        '';
      }
      {
        type = "lua";
        plugin = nvim-web-devicons;
        config = ''
          require('nvim-web-devicons').setup()
        '';
      }
      vim-scriptease
      vim-characterize
      vim-obsession
    ];
  };
}
