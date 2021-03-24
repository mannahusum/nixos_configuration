{ home, pkgs, programs, ...}:
{
  home = {
    packages = with pkgs; [
      gitAndTools.gh
    ];
    file.".config/pass-git-helper/git-pass-mapping.ini" = {
      text = ''
[github.com*]
target=github.com/mannahusum
      '';
    };
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    userEmail= "christian@wudika.de";
    extraConfig = {
      credential.helper = "${pkgs.gitAndTools.pass-git-helper}/bin/pass-git-helper";
    };
  };

}
