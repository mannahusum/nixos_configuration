{ pkgs, ... }:
{
  programs.neovim = {
    extraPackages = with pkgs; [
    ];

    plugins = with pkgs.vimPlugins; [
      plenary-nvim
      nui-nvim
      telescope-nvim
      telescope-fzf-native-nvim
      nvim-cmp
      snacks-nvim
      {
        type = "lua";
        plugin = avante-nvim;
        config = ''
          require("avante").setup({
            provider = "openai",
            mode = "agentic",
            instructions_file = "avante.md",
            providers = {
              openai = {
                endpoint = "https://ki-toolbox.scc.kit.edu/api/v1",
                model = "kit.qwen3.5-397b-A17b",
                timeout = 30000,
                api_key = "KIT_TOOLBOX_API_KEY",
              },
            },
            behaviour = {
              auto_suggestions = false,
              auto_set_highlist_group = true,
              auto_set_keymaps = true,
              auto_apply_diff_after_generation = false,
              support_paste_from_clipboard = false,
              minimize_diff = true,
              enable_token_counting = true,
              auto_add_current_file = true,
              auto_approve_tool_permission = true,
              confirmation_ui_style = "inline_buttons",
              acp_follow_agent_locations = true,
            },
            windows = {
              position = "left",
              wrap = true,
              width = 30,
            },
            input = {
              provider = "snacks",
              provider_opts = {
                title = "KI Toolbox",
                icon = " ",
              },
            },
            selector = {
              provider = "fzf_lua",
              provider_opts = {},
            },
          })
        '';
      }
    ];
  };
}


