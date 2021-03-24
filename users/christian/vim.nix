{ lib, pkgs, home, ... }:

{
  imports = [
    ./ssh.nix
  ];

  programs.git.ignores = [
    "*.swp"
  ];
  home = {
    packages = with pkgs; [ (
        vimHugeX.overrideAttrs (
          oldAttrs: rec {
            buildInputs = oldAttrs.buildInputs ++ (
              with pythonPackages; [
                jedi
              ]
            );
          }
        )
      )
    ];
    activation.checkoutVimConfig = lib.hm.dag.entryAfter ["installSSHprivateKey"] ''
      if [ ! -x $HOME/.vim ]; then
        $DRY_RUN_CMD git clone $VERBOSE_ARG git@github.com:mannahusum/vimrc_stuff.git $HOME/.vim
      fi
    '';
  };
}


