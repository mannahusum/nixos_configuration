{ pkgs, services, ... }:
{
  services.xscreensaver = {
    enable = true;
    settings = {
      newLoginCommand = "${pkgs.lightdm.out}/bin/dm-tool switch-to-greeter";
    };
  };

  xresources.extraConfig = builtins.readFile (
    (
      pkgs.fetchFromGitHub {
          owner = "solarized";
          repo = "xresources";
          rev = "0c426297b558965d462f0e45f87eb16a10586c53";
          sha256 = "1h013bmcl8ba49wxcnxqgp4grma3d6zrsszr320wr6i7anl4fdln";
      }
    ).out + "/Xresources.dark"
  );

}
