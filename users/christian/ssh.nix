{ pkgs, lib, ... }:

let
  mywudika = {
    hostname = "ssl.wudika.de";
    user = "manna";
  };

  writeShellScriptBinAndSymlink = name: text: pkgs.symlinkJoin {
    name = name;
    paths = [
      (pkgs.writeShellScriptBin name text)
    ];
  };

in let
  ssh_handler = writeShellScriptBinAndSymlink "ssh-handler.sh" ''
  user=root
  pattern='^(([[:alnum:]]+)://)?(([[:alnum:]]+)@)?([^:^@]+)(:([[:digit:]]+))?$'
  if [[ "''${1}" =~ $pattern ]]; then
          proto=''${BASH_REMATCH[2]}
          given_user=''${BASH_REMATCH[4]}
          host=''${BASH_REMATCH[5]}
          port=''${BASH_REMATCH[7]}
  fi
  [ -n "''${given_user}" ] && user="''${given_user}"
  ssh_command="${pkgs.openssh.out}/bin/ssh -l ''${user}"
  [ -n "''${port}" ] && ssh_command="$ssh_command -p ''${port}"
  ssh_command="$ssh_command ''${host}"
  [ -t 1 ] || ssh_command="${pkgs.alacritty.out}/bin/alacritty -t 'SSH: $host:$port' -e $ssh_command"
  echo "''${ssh_command}"
  eval "''${ssh_command}"
  '';
in {

  xdg.desktopEntries.ssh = {
    type="Application";
    name="OpenSSH";
    icon="call-start-symbolic.svg";
    comment="Open SSH-Connection to specified host";
    categories = [ "Network" ];
    exec="ssh-handler.sh";
    genericName="SSH";
    mimeType=[
      "x-scheme-handler/tcp"
      "x-scheme-handler/ssh"
    ];
    terminal=true;
  };
  xdg.mimeApps.defaultApplications."x-scheme-handler/ssh"= [
    "ssh.desktop"
  ];
  xdg.mimeApps.defaultApplications."x-scheme-handler/tcp"= [
    "ssh.desktop"
  ];
  home.packages = [
    ssh_handler
  ];

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
      "github.com" = {
        forwardX11 = false;
      };
    };
  };
  # home = {
  #   activation.installSSHprivateKey = lib.hm.dag.entryAfter ["writeBoundary"] ''
  #     $DRY_RUN_CMD mkdir -p $HOME/.ssh/controlmasters
  #     $DRY_RUN_CMD install -D -m600 ${./private/id_rsa} $HOME/.ssh/id_rsa
  #   '';
  # };
}

