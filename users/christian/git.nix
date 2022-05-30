{ home, pkgs, programs, ...}:
{
  home = {
    packages = with pkgs; [
      gitAndTools.gh
    ];
    file.".config/pass-git-helper/git-pass-mapping.ini" = {
      text = ''
[DEFAULT]
username_extractor=regex_search
regex_username=^user: (.*)$

[github.com*]
target=github-gist
      '';
    };
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    userEmail= "christian@wudika.de";
    extraConfig = {
      credential.helper = "${pkgs.gitAndTools.pass-git-helper}/bin/pass-git-helper";
      pull.rebase = false;
    };
  };

}
