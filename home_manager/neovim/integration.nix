{ pkgs, ... }:
{
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      {
        type = "viml";
        plugin = nvim-sops;
        config = ''
          nnoremap <localleader>Sd :SopsDecrypt<CR>
          nnoremap <localleader>Se :SopsEncrypt<CR>
        '';
      }
    ];
  };
}

