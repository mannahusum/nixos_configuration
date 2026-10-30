{
  config,
  lib,
  ...
}: let
  cfg = config.canetworking;
in {
  imports = [
  ];

  options.canetworking = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether there are domains to request a certificate for
      '';
    };
    # domains = lib.mkOption {
    #   type = lib.types.listOf lib.types.str;
    #   default = [];
    #   description = ''
    #     Domains for which to request certificates
    #   '';
    # };
  };

  config = lib.mkIf cfg.enable {
    services = {
      avahi = {
        enable = true;
        nssmdns4 = false;
        nssmdns6 = false;
        openFirewall = true;
        publish = {
          enable = true;
          addresses = true;
          workstation = true;
          userServices = true;
          hinfo = true;
        };
        ipv6 = true;
      };
      resolved = {
        enable = true;
        settings.Resolve = {
          DNSStubListenerExtra = "[::1]:53";
          DNSOverTLS = "true";
          DNSSEC = "true";
          Domains = ["~."];
          FallbackDNS = ["1.1.1.1#one.one.one.one.one" "1.0.0.1#one.one.one.one"];
          LLMNR = "true";
          MulticastDNS = "resolve";
        };
      };
    };

    networking = {
      enableIPv6 = true;
      tempAddresses = "disabled";
      nameservers = ["1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one"];
      useHostResolvConf = lib.mkForce false;
    };
  };
}
