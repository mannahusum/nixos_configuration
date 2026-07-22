{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.ca.gpg;
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
      pinentry = lib.mkOption {
        type = lib.types.enum ["noagent" "bemenu" "gnome3"];
        default = "noagent";
        example = "gnome3";
        description = ''
          pinentry to be used,
          depending on desktopManager and therefore displayManager
        '';
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf (cfg.pinentry == "bemenu") {
      services.gpg-agent.pinentry = {
        package = pkgs.pinentry-bemenu;
        program = "pinentry-bemenu";
      };
    })
    (mkIf (cfg.pinentry == "gnome3") {
      services.gpg-agent.pinentry = {
        package = pkgs.pinentry-gnome3;
        program = "pinentry-gnome3";
      };
    })
    (mkIf (cfg.pinentry != "noagent") {
      services.gpg-agent = {
        enable = true;
        enableBashIntegration = true;
        enableExtraSocket = true;
        enableScDaemon = true;
        enableSshSupport = true;
        grabKeyboardAndMouse = true;
      };
    })
    (mkIf (cfg.pinentry == "noagent") {
      services.gpg-agent.enable = false;
    })
    {
      home.packages = with pkgs; [
        git-crypt
      ];
      programs = {
        gpg = {
          enable = true;
          mutableKeys = true;
          mutableTrust = true;
        };
      };
      services.gpg-agent = {
        enable = true;
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


              check_sockets

              ${pkgs.gnupg}/bin/gpg --quiet --import "${pkgs.al_pgp_key}"
              importTrust "${pkgs.al_pgp_key}" 5
              unset GNUPGHOME keyId importTrust

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
    }
  ]);
}
