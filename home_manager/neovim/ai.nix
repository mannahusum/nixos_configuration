{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.ca.neovim.ai;
  aider_model_metadata_json = pkgs.writers.writeJSON ".aider.model.metadata.json" {
    "openai/kit.deepseek-v4-flash" = let
      context_size = 512 * 1024;
    in {
      max_input_tokens = context_size;
      max_tokens = context_size;
      max_output_tokens = context_size;
      input_cost_per_token = 0;
      output_cost_por_token = 0;
    };
  };
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
          aider-chat
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
                '<leader>AO',
                ':AiderOpen --model ${cfg.model} --model-metadata-file ${aider_model_metadata_json}<CR>',
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
