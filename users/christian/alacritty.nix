{ pkgs, ... }:

let
  # Base16 Solarized Light 256 - alacritty color config
  # Ethan Schoonover (modified by aramisgithub)
  solarized_light = {
    # Default colors
    primary = {
      background = "0xfdf6e3";
      foreground = "0x586e75";
    };

    # Colors the cursor will use if `custom_cursor_colors` is true
    cursor = {
      text = "0xfdf6e3";
      cursor = "0x586e75";
    };

    # Normal colors
    normal = {
      black =   "0xfdf6e3";
      red =     "0xdc322f";
      green =   "0x859900";
      yellow =  "0xb58900";
      blue =    "0x268bd2";
      magenta = "0x6c71c4";
      cyan =    "0x2aa198";
      white =   "0x586e75";
    };

    # Bright colors
    bright = {
      black =   "0x839496";
      red =     "0xdc322f";
      green =   "0x859900";
      yellow =  "0xb58900";
      blue =    "0x268bd2";
      magenta = "0x6c71c4";
      cyan =    "0x2aa198";
      white =   "0x002b36";
    };

    indexed_colors = [
      { index = 16; color = "0xcb4b16"; }
      { index = 17; color = "0xd33682"; }
      { index = 18; color = "0xeee8d5"; }
      { index = 19; color = "0x93a1a1"; }
      { index = 20; color = "0x657b83"; }
      { index = 21; color = "0x073642"; }
    ];
  };

  solarized_dark = {
    primary = {
      background = "#002b36"; # base03
      foreground = "#839496"; # base0
    };

    # Cursor colors
    cursor = {
      text =   "#002b36"; # base03
      cursor = "#839496"; # base0
    };

    # Normal colors
    normal = {
      black =   "#073642"; # base02
      red =     "#dc322f"; # red
      green =   "#859900"; # green
      yellow =  "#b58900"; # yellow
      blue =    "#268bd2"; # blue
      magenta = "#d33682"; # magenta
      cyan =    "#2aa198"; # cyan
      white =   "#eee8d5"; # base2
    };

    # Bright colors
    bright = {
      black =   "#002b36"; # base03
      red =     "#cb4b16"; # orange
      green =   "#586e75"; # base01
      yellow =  "#657b83"; # base00
      blue =    "#839496"; # base0
      magenta = "#6c71c4"; # violet
      cyan =    "#93a1a1"; # base1
      white =   "#fdf6e3"; # base3
    };
  };
in
{
  home.packages = with pkgs; [
    alacritty
  ];
  fonts.fonts = with pkgs; [
    nerdfonts
  ];
  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        normal = {
          family = "FiraCode Nerd Font Mono";
          style = "Regular";
        };
        size = 5.0;
      };
      window = {
        decorations = "none";
        dynamic_title = true;
      };

      schemes = {
        solarized_light = solarized_light;
        solarized_dark = solarized_dark;
      };

      colors = solarized_dark;

      scrolling = {
        history = 10000;
        multiplier = 3;
      };

      live_config_reload = true;
    };
  };
}
