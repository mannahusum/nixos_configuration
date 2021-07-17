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
    "awesome/rc.lua" = {
      text = (builtins.replaceStrings ["xterm"] ["${pkgs.alacritty.out}/bin/alacritty"] (builtins.readFile "${pkgs.awesome.out}/etc/xdg/awesome/rc.lua"));
    };
  };
}
