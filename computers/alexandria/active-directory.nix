{ config, lib, pkgs, networking, environment, ... }:
with lib;

let
  cfg = config.services.samba;
  samba = cfg.package;
  nssModulesPath = config.system.nssModules.path;
  adDomain = "windows.catbertsen.de";
  dcName = "alexandria.catbertsen.de";
  adWorkgroup = "CATA";
  adNetbiosName = "ALEXANDRIA";
  staticIp = "192.168.10.252";
  dnsForwarder = "192.168.10.1";
  smbShare = path: {
    inherit path;
    "read only" = "no";
    "map acl inherit" = "yes";
    "inherit acls" = "yes";
    "vfs objects" = "acl_xattr";
    "acl_xattr:default acl style" = "posix";
  };
in {
  # Disable resolveconf, we're using Samba internal DNS backend
  environment.etc = {
    "resolv.conf" = {
      text = ''
        search ${adDomain}
        nameserver ${staticIp}
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
  ];

  security.krb5 = {
    enable = true;
    package = pkgs.krb5;
    settings = {
      libdefaults = {
        udp_preference_limit = 0;
        default_realm = adDomain;
      };
      realms."${adDomain}" = {
        kdc = dcName;
        admin_server = dcName;
      };
    };
  };

  services.kerberos_server = {
    enable = true;
    settings = {
      realms."${adDomain}" = {
        acl = [{ principal = "adminuser"; access= ["add" "cpw"]; }];
      };
    };
  };

  # Rebuild Samba with LDAP, MDNS and Domain Controller support
  nixpkgs.overlays = [ (self: super: {
    samba = (super.samba.override {
      enableLDAP = true;
      enableMDNS = true;
      enableDomainController = true;
      enableProfiling = true; # Optional for logging
       # Set pythonpath manually (bellow with overrideAttrs) as it is not set on 22.11 due to bug
    }).overrideAttrs (finalAttrs: previousAttrs: {
        pythonPath = with super; [ python3Packages.dnspython python3Packages.markdown tdb ldb talloc ];
      });
  })];

  # Disable default Samba `smbd` service, we will be using the `samba` server binary
  systemd.services = {
    resolvconf.enable = false;
    samba-smbd.enable = false;
    samba = {
      description = "Samba Service Daemon";

      requiredBy = [ "samba.target" ];
      partOf = [ "samba.target" ];

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
  services.samba = {
    openFirewall = true;
    enable = true;
    nmbd.enable = false;
    winbindd.enable = false;
    settings = {
      global = {
        "dns forwarder" = dnsForwarder;
        "netbios name" =  adNetbiosName;
        "realm" = "${toUpper adDomain}";
        "server role" = "active directory domain controller";
        "workgroup" = adWorkgroup;
        "idmap_ldb:use rf2307" = "yes";
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
        "vfs objects" = "acl_xattr";
        "acl_xattr:default acl style" = "posix";
      };
      "tm_share" = {
        "path" = "/media/tm_share";
        "valid users" = "christian";
        "public" = "no";
        "writeable" = "yes";
        "force user" = "christian";
        "fruit:aapl" = "yes";
        "fruit:time machine" = "yes";
        "vfs objects" = "catia fruit streams_xattr acl_xattr";
        "acl_xattr:default acl style" = "posix";
      };
    };
  };
  networking.firewall.extraCommands = ''iptables -t raw -A OUTPUT -p udp -m udp --dport 137 -j CT --helper netbios-ns'';
}
