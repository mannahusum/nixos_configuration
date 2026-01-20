{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.samba;
  samba = cfg.package;
  # nssModulesPath = config.system.nssModules.path;
  adDomain = "windows.catbertsen.de";
  dcName = "rex.windows.catbertsen.de";
  adWorkgroup = "CATA";
  adNetbiosName = "ulpia";
  # staticIp = "192.168.10.252";
  # dnsForwarder = "192.168.10.251";
  dnsForwarder = "192.168.10.1";
  smbShare = path: {
    inherit path;
    "read only" = "no";
    "map acl inherit" = "yes";
    "inherit acls" = "yes";
    "vfs objects" = "fruit acl_xattr";
    "acl_xattr:default acl style" = "posix";
    "smb3 unix extensions" = "yes";
    "fruit:resource" = "xattr";
  };
in {
  # Disable resolveconf, we're using Samba internal DNS backend
  environment.etc = {
    "resolv.conf" = {
      text = ''
        search ${adDomain}
        nameserver ${dnsForwarder}
      '';
    };
  };

  environment.systemPackages = with pkgs; [
    adcli
    oddjob
    samba4Full
    sssd
    krb5
    realmd
    openldap
  ];

  security.krb5 = {
    enable = true;
    package = pkgs.krb5;
    settings = {
      libdefaults = {
        default_realm = lib.strings.toUpper adDomain;
        dns_lookup_realm = "false";
        dns_lookup_kdc = "true";
        dns_canonicalize_hostname = "true";
        rdns = "true";
      };
      realms."${lib.strings.toUpper adDomain}" = {
        default_domain = "${lib.strings.toLower adDomain}";
        # kdc = dcName;
        # admin_server = dcName;
      };
      "domain_realm" = {
        "${adNetbiosName}" = lib.strings.toUpper adDomain;
      };
    };
  };

  services = {
    ntp = {
      enable = true;
      servers = [
        "ptbtime1.ptb.de"
        "ptbtime2.ptb.de"
        "ptbtime3.ptb.de"
      ];
    };
  };

  # Rebuild Samba with LDAP, MDNS and Domain Controller support
  nixpkgs.overlays = [
    (_self: super: {
      samba =
        (super.samba.override {
          enableLDAP = false;
          enableMDNS = true;
          enableDomainController = false;
          enableProfiling = true; # Optional for logging
          # Set pythonpath manually (bellow with overrideAttrs) as it is not set on 22.11 due to bug
        })
        .overrideAttrs (_finalAttrs: _previousAttrs: {
          pythonPath = with super; [python3Packages.dnspython python3Packages.markdown tdb ldb talloc];
        });
    })
  ];

  # Disable default Samba `smbd` service, we will be using the `samba` server binary
  systemd.services = {
    resolvconf.enable = false;
    samba-smbd.enable = false;
    samba = {
      description = "Samba Service Daemon";

      requiredBy = ["samba.target"];
      partOf = ["samba.target"];

      serviceConfig = {
        ExecStart = "${samba}/sbin/samba --foreground --no-process-group";
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        LimitNOFILE = 16384;
        PIDFile = "/run/samba/samba.pid";
        Type = "notify";
        NotifyAccess = "all"; #may not do anything...
      };
      unitConfig.RequiresMountsFor = "/var/lib/samba";
    };
  };

  security.acme = {
    acceptTerms = true;
    useRoot = true;
    defaults.email = "christian@wudika.de";
    certs = {
      "ulpia.windows.catbertsen.de" = {
        dnsResolver = "205.251.193.108:53";
        dnsProvider = "route53";
        # credentialsFile = "/run/windows.catbertsen.de.env";
        credentialsFile = config.sops.templates."route53WindowsCatbertsenCredentials".path;
        webroot = null;
        postRun = ''
          ${pkgs.coreutils.out}/bin/chmod 600 key.pem
          # ${pkgs.coreutils.out}/bin/install -o root -g root -m 600 key.pem key4root.pem
        '';
      };
      "ulpia.catbertsen.de" = {
        dnsResolver = "205.251.194.49:53";
        dnsProvider = "route53";
        credentialsFile = config.sops.templates."route53CatbertsenCredentials".path;
        webroot = null;
        postRun = ''
          ${pkgs.coreutils.out}/bin/chmod 600 key.pem
          # ${pkgs.coreutils.out}/bin/install -o root -g root -m 600 key.pem key4root.pem
        '';
      };
      "rex.windows.catbertsen.de" = {
        dnsResolver = "205.251.193.108:53";
        dnsProvider = "route53";
        # credentialsFile = "/run/windows.catbertsen.de.env";
        credentialsFile = config.sops.templates."route53WindowsCatbertsenCredentials".path;
        webroot = null;
        postRun = ''
          ${pkgs.coreutils.out}/bin/chmod 600 key.pem
          # ${pkgs.coreutils.out}/bin/install -o root -g root -m 600 key.pem key4root.pem
        '';
      };
      "rex.catbertsen.de" = {
        dnsResolver = "205.251.194.49:53";
        dnsProvider = "route53";
        credentialsFile = config.sops.templates."route53CatbertsenCredentials".path;
        webroot = null;
        postRun = ''
          ${pkgs.coreutils.out}/bin/chmod 600 key.pem
          # ${pkgs.coreutils.out}/bin/install -o root -g root -m 600 key.pem key4root.pem
        '';
      };
    };
  };

  system = {
    nssModules = [config.services.samba.package];
    nssDatabases = {
      hosts = ["wins"];
      passwd = ["winbind"];
      group = ["winbind"];
    };
  };

  services = {
    samba = {
      openFirewall = true;
      enable = true;
      nmbd.enable = false;
      winbindd.enable = false;
      settings = {
        global = {
          "dns forwarder" = dnsForwarder;
          "netbios name" = adNetbiosName;
          "realm" = "${toUpper adDomain}";
          "server role" = "member server";
          "workgroup" = adWorkgroup;
          "idmap_ldb:use rf2307" = "yes";
          "fruit:aapl" = "yes";
          "tls cafile" = "/etc/ssl/certs/ca-certificates.crt";
          "tls certfile" = "/var/lib/acme/${toLower dcName}/cert.pem";
          "tls enabled" = "yes";
          "tls keyfile" = "/var/lib/acme/${toLower dcName}/key.pem";
          "tls verify peer" = "ca_and_name_if_available";
          "winbind nss info" = "rfc2307";
        };
        homes = {
          "read only" = "no";
          "comment" = "Home directories";
          "valid users" = "%S";
          "vfs objects" = "fruit acl_xattr";
          "fruit:resource" = "xattr";
        };
        sysvol = {
          path = "/var/lib/samba/sysvol";
          "read only" = "No";
        };
        netlogon = {
          path = "/var/lib/samba/sysvol/${adDomain}/scripts";
          "read only" = "No";
        };
        audio = smbShare "/media/audio";
        wii = smbShare "/media/games/wii";
        video = smbShare "/media/video";
        ultrastar = smbShare "/media/ultrastar";
        onqm = {
          path = "/media/onqm";
          "public" = "no";
          "valid users" = "christian";
          "read only" = "no";
          "map acl inherit" = "yes";
          "inherit acls" = "yes";
          "vfs objects" = "fruit acl_xattr";
          "acl_xattr:default acl style" = "posix";
          "access based share enum" = "yes";
          # "hide unreadable" = "yes";
          "smb3 unix extensions" = "yes";
        };
        "tm_share" = {
          "path" = "/media/tm_share";
          "valid users" = "christian";
          "public" = "no";
          "writeable" = "yes";
          "force user" = "christian";
          "fruit:aapl" = "yes";
          "fruit:time machine" = "yes";
          "fruit:resource" = "xattr";
          "vfs objects" = "catia fruit streams_xattr acl_xattr";
          "acl_xattr:default acl style" = "posix";
          "smb3 unix extensions" = "yes";
        };
      };
    };
    avahi = {
      enable = true;
      nssmdns4 = mkDefault true;
      extraServiceFiles = {
        smb = ''
          <?xml version="1.0" standalone='no'?>
          <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
          <service-group>
           <name replace-wildcards="yes">%h</name>
           <service>
             <type>_smb._tcp</type>
             <port>445</port>
           </service>
           <service>
             <type>_device-info._tcp</type>
             <port>0</port>
             <txt-record>model=RackMac</txt-record>
           </service>
          </service-group>
        '';
        ssh = "${pkgs.avahi}/etc/avahi/services/ssh.service";
      };

      publish = {
        enable = true;
        domain = true;
        addresses = true;
      };
    };
  };

  networking = {
    hostName = adNetbiosName;
    domain = adDomain;
    firewall.extraCommands = ''iptables -t raw -A OUTPUT -p udp -m udp --dport 137 -j CT --helper netbios-ns'';
  };
}
