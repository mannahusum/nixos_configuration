{ pkgs, ... }:
{
  programs.neovim = {

    extraPackages = with pkgs; [
      git
    ];

    plugins = with pkgs.vimPlugins; [
      {
        type = "viml";
        plugin = vim-fugitive;
        config = ''
          nnoremap <leader>gc :Git commit<CR>
          nnoremap <leader>gg :Git<CR>
          nnoremap <leader>gw :Gwrite<CR>
          nnoremap <leader>gl :Gclog<CR>

          " Fugitive Conflict Resolution
          nnoremap <leader>gd :Gvdiff<CR>
          nnoremap <leader>h :diffget //2<CR>
          nnoremap <leader>l :diffget //3<CR>

          " Push and pull
          nnoremap <leader>gf :Git fetch<CR>
          nnoremap <leader>gp :Git pull<CR>
          nnoremap <leader>gu :Git push<CR>
          nnoremap <leader>gL :Git push --force-with-lease<CR>
          nnoremap <leader>gU :Git -c push.default=current push<CR>
        '';
      }
    ];
  };
}
