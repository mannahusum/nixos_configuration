{ pkgs, lib, ... }:

let
  mywudika = {
    hostname = "ssl.wudika.de";
    user = "manna";
  };
in {
  programs.ssh = {
    enable = true;
    controlMaster = "yes";
    controlPath = "~/.ssh/controlmasters/%r@%h:%p";
    controlPersist = "10m";
    hashKnownHosts = false;
    forwardAgent = false;
    matchBlocks = {
      "wudika" = mywudika;
      "*.wudika.de" = mywudika;
      "wudika.de" = mywudika;
    };
  };
  home = {
    activation.installSSHprivateKey = lib.hm.dag.entryAfter ["writeBoundary"] ''
      $DRY_RUN_CMD mkdir -p $HOME/.ssh/controlmasters
      $DRY_RUN_CMD install -D -m600 ${./private/id_rsa} $HOME/.ssh/id_rsa
      if [ -z "$SSH_AUTH_SOCK" -o ! -r "$SSH_AUTH_SOCK" ] ; then
        $DRY_RUN_CMD eval `ssh-agent -s`
        $DRY_RUN_CMD ssh-add
      fi
    '';
  };
}

