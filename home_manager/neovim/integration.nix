{ pkgs, ... }:
{
  programs.neovim = {
    extraPackages = with pkgs; [
      fzf
      git
      ripgrep
      tree-sitter
      fd
      bat
      viu
      chafa
      ueberzugpp
      luarocks
      lua
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
      (nvim-treesitter.withPlugins (p: [
        p.bash
        p.c
        p.cmake
        p.comment
        p.cpp
        p.css
        p.csv
        p.d
        p.devicetree
        p.diff
        p.dockerfile
        p.git-config
        p.gitattributes
        p.gitcommit
        p.gitignore
        p.hcl
        p.html
        p.htmldjango
        p.http
        p.ini
        p.jinja
        p.jq
        p.json
        p.latex
        p.lua
        p.luadoc
        p.make
        p.markdown
        p.markdown_inline
        p.muttrc
        p.nginx
        p.nix
        p.passwd
        p.powershell
        p.printf
        p.python
        p.readline
        p.regex
        p.robots_txt
        p.sql
        p.ssh_config
        p.tcl
        p.toml
        p.tsx
        p.udev
        p.vhdl
        p.vim
        p.vimdoc
        p.xml
        p.yaml
        p.zathurarc
      ]))
      rocks-nvim
      rest-nvim
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
    ];
  };
}

