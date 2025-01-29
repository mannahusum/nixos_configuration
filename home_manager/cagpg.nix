{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.ca.gpg;

  mykey = builtins.fetchurl {
    url = "https://keys.openpgp.org/vks/v1/by-fingerprint/F1A1F1A33787F28359E60BFB1DBDE5EC541E1874";
    sha256 = "1r5g5bg01fvkb2flyw75hin4gvifn8za93przr6jf2bd2vx5qic5";
  };
in {
  imports = [
    ./bashprofile.nix
    ./cassh.nix
  ];

  options = {
    ca.gpg = {
      enable = mkEnableOption "Generate GPG configuration";
      withExtraSocket = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether there are two gpg agent sockets, the normal one and extra
        '';
      };
      forwardTo = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Directory in which the forwarded sockets reside
          An empty string, if there are no forwarded sockets
        '';
      };
      createForwardPath = mkOption {
        type = types.bool;
        default = false;
        description = ''
          create the path the sockets will be forwarded to - usefull for forwarding via SSH_AUTH_SOCK
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    programs = {
      gpg = {
        enable = true;
        mutableKeys = true;
        mutableTrust = true;
      };
    };
    services.gpg-agent = {
      enable = false;
      enableBashIntegration = true;
      enableExtraSocket = true;
      enableScDaemon = true;
      enableSshSupport = true;
      grabKeyboardAndMouse = true;
    };
    home.file."${config.programs.gpg.homedir}/scdaemon.conf".text = ''
      disable-ccid
    '';

    ca = {
      ssh.localGpgSocket =
        if cfg.withExtraSocket
        then "${cfg.forwardTo}/S.gpg-agent.extra"
        else "${cfg.forwardTo}/S.gpg-agent";
      bash = {
        enable = true;
        extraProfile.importGpgKey = ''

          gpgKeyId() {
              ${pkgs.gnupg}/bin/gpg --quiet --show-key --with-colons "$1" \
                  | grep ^pub: \
                  | cut -d: -f5
          }

          importTrust() {
              local keyIds trust
              IFS='\n' read -ra keyIds <<< "$(gpgKeyId "$1")"
              trust="$2"
              for id in "''${keyIds[@]}" ; do
                  { echo trust; echo "$trust"; (( trust == 5 )) && echo y; echo quit; } \
                  | ${pkgs.gnupg}/bin/gpg --quiet --no-tty --command-fd 0 --edit-key "$id" 2>/dev/null
              done
          }

          ${pkgs.gnupg}/bin/gpg --quiet --import "${mykey}"
          importTrust "${mykey}" 5

          unset importTrust
        '';
        extraProfile.gpgForwardedSockets =
          if (cfg.forwardTo == null)
          then ""
          else ''
            ${optionalString cfg.createForwardPath "mkdir -p ${cfg.forwardTo}"}

            override_gpg_sockets() {
                local key dirname path
                local -A gpg_replacement_paths=([agent-socket]=${cfg.forwardTo}/S.gpg-agent [agent-extra-socket]=${cfg.forwardTo}/S.gpg-agent.extra [agent-ssh-socket]=${cfg.forwardTo}/ssh-agent)
                for key in "''${!gpg_replacement_paths[@]}"; do
                    path="$(${pkgs.gnupg}/bin/gpgconf --list-dir ''${key})"
                    new="''${gpg_replacement_paths[$key]}"
                    if [ -n "''${path}" -a -n "''${new}" ]; then
                        dirname="$(${pkgs.coreutils}/bin/dirname "''${path}")"
                    if [ -d "''${dirname}" ]; then
                        ${pkgs.coreutils}/bin/rm -f "''${path}" || true
                        ${pkgs.coreutils}/bin/printf '%%Assuan%%\nsocket='"''${new}"'\n' >"''${path}"
                    fi
                    fi
                done
            }

            test_socket() {
                local type="$1"; shift
                local socket="$1"; shift
                [ -e "''${socket}" ] || return 1
                if [ "''${type}" = agent-ssh-socket ]; then
                    SSH_AUTH_SOCK="''${socket}" ${pkgs.openssh}/bin/ssh-add -L >/dev/null
                    # an exit code of 1 means no certificats. Only higher mean something is broken
                    [ $? -le 1 ]
                else
                    echo BYE | ${pkgs.socat}/bin/socat "UNIX-CONNECT:''${socket}" - 2>/dev/null | ${pkgs.gnugrep}/bin/grep OK >/dev/null
                fi
            }

            check_socket() {
                local agent_type="$1"; shift
                local old_socket="$(${pkgs.gnupg}/bin/gpgconf --list-dir ''${agent_type})"
                local new_socket
                socket="''${old_socket}"
                if [ -f "''${old_socket}" ]; then
                    new_socket="$(${pkgs.gnused}/bin/sed -E -n 's/^socket=(.*)+$/\1/p' <"''${socket}")"
                    if [ -z "''${new_socket}" ]; then
                        rm -f "''${old_socket}"
                    else
                        socket="''${new_socket}"
                    fi
                fi
                if test_socket "''${agent_type}" "''${socket}"; then
                    :
                else
                    rm -f "''${old_socket}" "''${socket}"
                fi
            }

            check_sockets() {
                for socket_type in agent-socket agent-extra-socket agent-ssh-socket; do
                    check_socket "''${socket_type}"
                done
            }


            check_sockets

            unset GNUPGHOME

            [ -S "$(${pkgs.gnupg}/bin/gpgconf --list-dirs agent-socket)" ] \
                && ${pkgs.gnupg}/bin/gpgconf --kill gpg-agent 2>&1

            override_gpg_sockets
            unset -f override_gpg_sockets

            check_sockets

            unset -f test_socket
            unset -f check_socket
            unset -f check_sockets
          '';
      };
    };
  };
}
