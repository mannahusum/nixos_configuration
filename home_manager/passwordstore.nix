{
  config,
  lib,
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
      wsl = {
        enable = mkEnableOption "Use WSL integration";
      };
    };
  };

  config = mkIf cfg.enable {
    programs.password-store = {
      enable = true;
      settings =
        {
          PASSWORD_STORE_DIR = "$HOME/.password-store";
        }
        // (
          if cfg.wsl.enable
          then {
            PASSWORD_STORE_ENABLE_EXTENSIONS = "true";
          }
          else {}
        );
    };

    ca = {
      ssh.enable = true;
      bash.extraProfile.downloadPasswordStore = hm.dag.entryAfter ["gpgForwardedSockets"] ''
        if [ ! -e $HOME/.password-store ]; then
            if (ssh-add -L | grep ssh >/dev/null); then
                git clone manna@ssl.wudika.de:password-store.git $HOME/.password-store
            fi
        fi
      '';

      bash.extraProfile.set_proxmox_secrets = ''
        set_proxmox_secrets() {
          local array
          local first

          first=""
          while read -ra array; do
            if [[ -z "$first" ]]; then
              export PROXMOX_TOKEN="''${array[0]}"
              first="1"
            else
              case "''${array[0]}" in
                user*)
                  export PROXMOX_USER="''${array[1]}"
                  ;;
              esac
            fi
          done < <(pass kit.edu/virt1.itiv.kit.edu/TerraformTest 2>/dev/null) 2>&1 >/dev/null
        }
      '';
    };
  };
}
