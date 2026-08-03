{ pkgs, ... }:
{
  programs.neovim = {
    extraPackages = with pkgs; [
      aider-chat-full
    ];

    extraPython3Packages = ps: with ps; [
      botocore
    ];

    plugins = with pkgs.vimPlugins; [
      {
        type = "lua";
        plugin = aider-nvim;
        config = ''
          require('aider').setup({
            auto_manage_context = true,
            default_bindings = true,
            debug = true,
            vim = true,
            ignore_buffers = {
              '^term:',
            },
            border = {
              style = {
                "╭", "─", "╮", "│", "╯", "─", "╰", "│"
              },
              color = "#fab387",
            },

          })

          vim.api.nvim_set_keymap(
            'n',
            '<leader>Ao',
            ':AiderOpen --model openai/kit.qwen3.5-397b-A17b<CR>',
            {
              noremap = true,
              silent = true,
            }
          )
        '';
      }
    ];
  };
}


