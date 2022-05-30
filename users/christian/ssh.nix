{ pkgs, lib, ... }:

# TODO:
# Check with Jochen regarding offline hosts
# Reconfigure SSH-Key for
# - S1222
# - S1240
# - S1234
# - S1264
# - S1223

# offline hosts

# onsite-milan-s1086
# 1.tcp.eu.ngrok.io:23150

# onsite-milan-s1085
# 1.tcp.eu.ngrok.io:23151

# onsite-south-hartford-s1052
# 1.tcp.ngrok.io:24579

# onsite-buenosaires-aroyovega-s1064
# 1.tcp.ngrok.io:24587

# onsite-kemano-s1135
# 1.tcp.ngrok.io:24598

# onsite-guangzhou-s1152
# 1.tcp.ap.ngrok.io:20330

# onsite-guangzhou-s1153
# 1.tcp.ap.ngrok.io:20335

# onsite-murnane-s1045
# 1.tcp.ap.ngrok.io:20356

# onsite-thomson-east-coast-line-s1016
# 1.tcp.ap.ngrok.io:20368

# TP3118-Slavkaliy-Nezhinsky-SBR-HAG
# 1.tcp.eu.ngrok.io:23321

# onsite-daegokss-s1108
# 1.tcp.ap.ngrok.io:20226

# TP 2017 3229 Zhujiang Water Delivery Project S-1159
# 1.tcp.ap.ngrok.io:20414

# onsite-daegokss-s1109
# 1.tcp.ap.ngrok.io:20423

# S-1144_sync4up
# 1.tcp.ap.ngrok.io:21204

# Shanghai-Chongming-Gas-Pipeline-M-2326
# 1.tcp.ap.ngrok.io:21205

# testing
# 1.tcp.ap.ngrok.io:21205

# TP-3304-Nanjing-Heyanlu-S1189
# 1.tcp.ap.ngrok.io:21274

# tp3187-20-jinanjiluoroad-yrct s-1177
# 1.tcp.ap.ngrok.io:21314

# TP2121-30-onsite-afsar-bagbasi-palet-S-1162
# 1.tcp.ap.ngrok.io:22143

# AutomaticTesting
# 1.tcp.eu.ngrok.io:26740

# vdms-s1245a-vdms
# 1.tcp.ap.ngrok.io:20465

# tp3327-30-pearl-rdwra-s1246a
# 1.tcp.ap.ngrok.io:20493

# tp2445-30-hanoi-ml3-s1254
# 1.tcp.ap.ngrok.io:20555

# tp3364-30-snowy-hydro
# 1.tcp.au.ngrok.io:24527

# tp3327-40-guangdong-s1269a
# 1.tcp.ap.ngrok.io:20604

# tp3364-30-snowy-hydro-S1221
# 1.tcp.au.ngrok.io:24529

# vdms-s1250a
# 1.tcp.ap.ngrok.io:20628

# tp3132-30-bangalore-mp2l4itd-s840b
# 1.tcp.ap.ngrok.io:20558

# tp3132-30-bangalore-l4itd-s839b
# 1.tcp.ap.ngrok.io:20634

# tp3132-30-bangalore-l4itd-s840b
# 1.tcp.ap.ngrok.io:20637

# vdms-s-1251a
# 1.tcp.ap.ngrok.io:20639

# TSA-S-1144 (nur VDMS)
# 1.tcp.ap.ngrok.io:20686

# TSA-S-1175up s-1136-tsa
# 1.tcp.au.ngrok.io:24568

# vdms-s1250a-2
# 1.tcp.ap.ngrok.io:20746

# standard
# 1.tcp.eu.ngrok.io:27768

# cccc-273-ubuntu-4
# 1.tcp.ap.ngrok.io:20760

# cccc-273-ubuntu-3
# 1.tcp.ap.ngrok.io:20764

#  cccc-273-ubuntu-2
# 1.tcp.ap.ngrok.io:20765

# cccc-266-ubuntu-3
# 1.tcp.ap.ngrok.io:20745

# vdms-s1235a-vdms
# 1.tcp.ap.ngrok.io:20788

# vdms-s1226
# 1.tcp.ap.ngrok.io:20730

# vdms-s1245a
# 1.tcp.ap.ngrok.io:20770

# tp2837-10-frankfurt-ubl-5
# 3.tcp.eu.ngrok.io:20201

# tp3327-30-pearl-rdwra-s1246a-staging
# 1.tcp.ap.ngrok.io:20852

# https://ccm2l.vmt-gmbh.info:8443/vdms
# 1.tcp.sa.ngrok.io:26538

let
  vdms_default_user_old = "root";
  vdms_default_user_new = "vdmsadmin";

  vdms_hosts_new = [
    {
      name="TP3187-10-JinanJiluoRoad-YRCT S-1176";
      machine="S1176";
      address="1.tcp.ap.ngrok.io:20325";
    }
    {
      name="vdms-s1222";
      machine="S1222";
      address="1.tcp.eu.ngrok.io:24470";
    }
    {
      name="TP3462 Dobongsan Okjung Subway Line 7 Extension S-1225A";
      machine="S1225";
      address="1.tcp.ap.ngrok.io:21284";
    }
    {
      name="tp2445-30-hanoi-ml3-s1255";
      machine="S1255";
      address="1.tcp.ap.ngrok.io:20553";
    }
    {
      name="tp3194-20-ghella-abergeldie-s1240a";
      machine="S1240";
      address="1.tcp.ap.ngrok.io:20600";
    }
    {
      name="tp3327-30-guangdong-s1268a";
      machine="S1268";
      address="1.tcp.ap.ngrok.io:22042";
    }
    {
      name="vdms-tp3551";
      machine="S1256";
      address="1.tcp.ap.ngrok.io:20657";
    }
    {
      name="tp3489-30-guangzhou-s1234";
      machine="S1234";
      address="1.tcp.ap.ngrok.io:20666";
    }
    {
      name="http://vdms-s1269a-vdms.ap.ngrok.io/vdms/ ????";
      machine="S1269";
      address="1.tcp.ap.ngrok.io:21255";
    }
    {
      name="tp3327-30-china-rtscl-s1248a";
      machine="S1248";
      address="1.tcp.ap.ngrok.io:20669";
    }
    {
      name="1.tcp.au.ngrok.io:24568";
      machine="S1276";
      address="1.tcp.ap.ngrok.io:20701";
    }
    {
      name="tp3605-20-china-railway-14thb-s1277";
      machine="S1277";
      address="1.tcp.ap.ngrok.io:20735";
    }
    {
      name="cccc-273-ubuntu-1";
      machine="THDG19273";
      address="1.tcp.ap.ngrok.io:20759";
    }
    {
      name="tp3678-20-guangzhou-zr-s1289";
      machine="S1289";
      address="1.tcp.ap.ngrok.io:20733";
    }
    {
      name="tp3050-lot1-afcons-S1264a";
      machine="S1264";
      address="1.tcp.in.ngrok.io:22161";
    }
    {
      name="vdms-s1223";
      machine="S1223";
      address="3.tcp.eu.ngrok.io:22085";
    }
    {
      name="cccc-266-ubunut-1";
      machine="THDG19267";
      address="1.tcp.ap.ngrok.io:20816";
    }
    {
      name="tp3132-40-lot1-afcons-s1259a";
      machine="S1259";
      address="1.tcp.in.ngrok.io:22276";
    }
    {
      name="tp3132-40-lot1-afcons-S1260a";
      machine="S1260";
      address="1.tcp.in.ngrok.io:22279";
    }
    {
      name="cccc-266-ubuntu-2";
      machine="THDG19266";
      address="1.tcp.ap.ngrok.io:20801";
    }
    {
      name="tp3327-30-china-railway-tscl-s1247a";
      machine="S1247";
      address="1.tcp.ap.ngrok.io:20886";
    }
    {
      name="tp3494-20-guangzhou-ml12-s1233a";
      machine="S1233";
      address="1.tcp.ap.ngrok.io:20897";
    }
    {
      name="outfall-s1230a";
      machine="S1230";
      address="1.tcp.ngrok.io:29396";
    }
    {
      name="tp3200-20-wuhan-heping-ase";
      machine="S1218";
      address="1.tcp.ap.ngrok.io:20951";
    }
    {
      name="vdms-s1220";
      machine="S1220";
      address="1.tcp.au.ngrok.io:25868";
    }
    {
      name="vdms-s1221";
      machine="S1221";
      address="1.tcp.au.ngrok.io:24529";
    }
  ];
  vdms_hosts_old = [
  ];

in let
  vdms_matchblocks = user: vdms_hosts: (builtins.listToAttrs (map (
    x: let
      splitaddress = builtins.split ":" x.address;
    in {
      name = x.machine + "A";
      value = {
        user = user;
        hostname = builtins.elemAt splitaddress 0;
        port = lib.toInt (builtins.elemAt splitaddress 2);
        identitiesOnly = true;
        identityFile = "~/.ssh/RED.pub";
      };
    }
  ) vdms_hosts ));
in let
  vdms_matchblocks_new = vdms_matchblocks vdms_default_user_new vdms_hosts_new;
  vdms_matchblocks_old = vdms_matchblocks vdms_default_user_old vdms_hosts_old;
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
  user=vdmsadmin
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
    controlMaster = "auto";
    controlPath = "~/.ssh/controlmasters/%r@%h:%p";
    controlPersist = "10m";
    hashKnownHosts = false;
    forwardAgent = false;
    matchBlocks = lib.mkMerge [
      vdms_matchblocks_old
      vdms_matchblocks_new
      (
        {
          "wudika" = mywudika;
          "*.wudika.de" = mywudika;
          "wudika.de" = mywudika;
          "github.com" = {
            forwardX11 = false;
          };
          "SSHProxy" = {
            user = "calbertsen";
            hostname = "54.169.217.33";
          };
          "S1221S" = {
            user = "root";
            proxyCommand = "${pkgs.openssh.out}/bin/ssh SSHProxy -W 127.0.0.1:6221";
          };
          "*.vmt-gmbh.info" = {
            user = "vdmsadmin";
            identitiesOnly = true;
            identityFile = "~/.ssh/RED.pub";
          };
          "serial-console.ec2-instance-connect.*.aws" = {
            identitiesOnly = true;
            identityFile = "~/.ssh/RED.pub";
            extraOptions = {
              HostKeyAlgorithms = "+ssh-rsa";
              ControlPath = "~/.ssh/controlmasters/ec2-console";
            };
          };
        }
      )
    ];
  };
  # home = {
  #   activation.installSSHprivateKey = lib.hm.dag.entryAfter ["writeBoundary"] ''
  #     $DRY_RUN_CMD mkdir -p $HOME/.ssh/controlmasters
  #     $DRY_RUN_CMD install -D -m600 ${./private/id_rsa} $HOME/.ssh/id_rsa
  #   '';
  # };
}

