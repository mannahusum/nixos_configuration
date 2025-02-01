{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.ca.pass;
in {
  imports = [
    ./cassh.nix
  ];

  options = {
    ca.pass = {
      enable = mkEnableOption "Initialize Password Store";
    };
  };

  config = mkIf cfg.enable {
    programs.password-store = {
      enable = true;
      settings = {
        PASSWORD_STORE_DIR = "$HOME/.password-store";
      };
    };

    ca.ssh.enable = true;
    ca.bash.extraProfile.downloadPasswordStore = hm.dag.entryAfter ["gpgForwardedSockets"] ''
      if [ ! -e $HOME/.password-store ]; then
          if (ssh-add -L | grep ssh >/dev/null); then
              git clone manna@ssl.wudika.de:password-store.git $HOME/.password-store
          fi
      fi
    '';
  };
}
