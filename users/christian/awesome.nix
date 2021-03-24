{ pkgs, xdg, xsession, ... }:
{
  xsession.windowManager.awesome = {
    enable = true;
    noArgb = true;
    luaModules = with pkgs.luaPackages; [
      luarocks
    ];
  };
  xdg.configFile = {
    "awesome/rc.lua".source = pkgs.substituteAll {
      # terminal = "${pkgs.tabbed.out}/bin/tabbed -c ${pkgs.alacritty.out}/bin/alacritty --embed";
      terminal = "${pkgs.alacritty.out}/bin/alacritty";
      src = ./rc.lua;
    };
  };
}
