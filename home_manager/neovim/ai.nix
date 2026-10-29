{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.ca.neovim.ai;
in
  with lib; {
    imports = [
    ];

    options = {
      ca.neovim.ai = {
        enable = mkEnableOption "Generate Neovim configuration";
        model = mkOption {
          type = types.str;
          default = "openai/kit.qwen3.5-397b-A17b";
          description = "which model to run for AI";
        };
      };
    };

    config = mkIf cfg.enable {
      programs.neovim = {
        extraPackages = with pkgs; [
          aider-chat-full
        ];

        extraPython3Packages = ps:
          with ps; [
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
                ':AiderOpen --model ${cfg.model}<CR>',
                {
                  noremap = true,
                  silent = true,
                }
              )
            '';
          }
        ];
      };
    };
  }
