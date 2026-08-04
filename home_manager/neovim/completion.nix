{pkgs, ...}: {
  imports = [
    ./treesitter.nix
  ];

  programs.neovim = {
    extraPackages = with pkgs; [
      ansible-language-server
      bash-language-server
      gh
      glab
      nixd
      lua-language-server
      pyright
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
                  score_offset = 150,
                  opts = { insert = true, },
                },
                git = {
                  module = 'blink-cmp-git',
                  name = 'git',
                  score_offset = 50,
                  opts = {
                    commit = { },
                  },
                },
                lsp = {
                  name = 'LSP',
                  module = 'blink.cmp.sources.lsp',
                  score_offset = 200,
                },
                path = {
                  name = 'Path',
                  module = 'blink.cmp.sources.path',
                  score_offset = 175,
                  opts = {
                    trailing_slash = true,
                  },
                },
                buffer = {
                  name = 'Buffer',
                  module = 'blink.cmp.sources.buffer',
                  min_keyword_length = 3,
                  score_offset = 188,
                },
                snippets = {
                  name = 'Snippets',
                  module = 'blink.cmp.sources.snippets',
                  min_keyword_length = 2,
                  score_offset = 118,
                },
              },
            },
          })
        '';
      }
      blink-cmp-dictionary
      blink-emoji-nvim
      blink-cmp-git
      friendly-snippets

      astrolsp
      {
        type = "lua";
        plugin = nvim-lspconfig;
        config = ''
          local lsp_capabilities = require('blink.cmp').get_lsp_capabilities()
          vim.lsp.config('ansiblels', { capabilities = lsp_capabilities })
          vim.lsp.config('bashls', { capabilities = lsp_capabilities })
          vim.lsp.config('lua_ls', { capabilities = lsp_capabilities })
          vim.lsp.config('nixd', {
            capabilities = lsp_capabilities,
          })
          vim.lsp.config('powershell_es', {
            bundle_path = '${pkgs.powershell-editor-services.out}',
            shell = '${pkgs.powershell}/bin/pwsh',
            capabilities = lsp_capabilities
          })
          vim.lsp.config('pyright', { capabilities = lsp_capabilities })
          vim.lsp.enable({'ansiblels', 'bashls', 'lua_ls', 'nixd', 'powershell_es', 'pyright'})
        '';
      }
    ];
  };
}
