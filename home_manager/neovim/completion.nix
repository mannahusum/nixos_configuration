{ pkgs, ... }:
{
  programs.neovim = {
    extraPackages = with pkgs; [
      gh
      glab
      nixd
      wordnet
    ];

    plugins = with pkgs.vimPlugins; [
      {
        type = "lua";
        plugin = blink-cmp;
        config = ''
          require('blink-cmp').setup({
            keymap = {
              preset = 'default',
            },
            sources = {
              default = { "lsp", "path", "buffer", "emoji", "dictionary", "git" },
              providers = {
                dictionary = {
                  module = "blink-cmp-dictionary",
                  name = "dict",
                  score_offset = 100,
                  min_keyword_length = 3,
                },
                emoji = {
                  async = true,
                  module = "blink-emoji",
                  name = "emoji",
                  score_offset = 15,
                  opts = { insert = true, },
                },
                git = {
                  module = 'blink-cmp-git',
                  name = 'git',
                  score_offset = 100,
                  opts = {
                    commit = { },
                  },
                },
              },
            },
          })
        '';
      }
      blink-cmp-dictionary
      blink-emoji-nvim
      blink-cmp-git

      {
        type = "lua";
        plugin = nvim-lspconfig;
        config = ''
          local lsp_capabilities = require('blink.cmp').get_lsp_capabilities()
          vim.lsp.config('nixd', { capabilities = lsp_capabilities })
          vim.lsp.enable('nixd')
        '';
      }
    ];
  };
}
