# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
{
  imports =
    [
      ./fonts.nix
      ./x11.nix
      ./xscreensaver.nix
      ./guiusers.nix
      ./dropbox.nix
      ./virtualization.nix
      ./printing.nix
      ./passwords.nix
      ./raspberry-pi-zero-buildtools.nix
    ];

  networking = {
  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
    networkmanager = {
      dhcp = "dhclient";
      dns = "unbound";
      enable = true;
    };
    timeServers = [
      "ptbtime1.ptb.de"
      "ptbtime2.ptb.de"
      "ptbtime3.ptb.de"
    ];
  };

  # Select internationalisation properties.
  # i18n.defaultLocale = "de_DE.UTF-8";
  console = {
    # earlySetup = true;
    font = "Lat2-Terminus16";
    # Solarized :)
    colors = [
      "002b36"
      "dc322f"
      "859900"
      "b58900"
      "268bd2"
      "d33682"
      "2aa198"
      "eee8d5"
      "002b36"
      "cb4b16"
      "586e75"
      "657b83"
      "839496"
      "6c71c4"
      "93a1a1"
      "fdf6e3"
    ];

    packages = with pkgs; [
      terminus_font
    ];

    useXkbConfig = true;
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    cacert
    efitools
    file
    findutils
    gptfdisk
    less
    lesspipe
    lm_sensors
    mlocate
    vim
    wget
    xsaneGimp
  ];

  environment.etc."mdadm.conf".text = ''
    MAILADDR christian@wudika.de
  '';


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.ssh.forwardX11 = true;
  programs = {
    adb.enable = true;
    bash = {
      enableCompletion = true;
      enableLsColors = true;
    };
    cdemu = {
      enable = true;
      gui = true;
      image-analyzer = true;
    };
    command-not-found.enable = true;
    dconf = {
      enable = true;
    };
    fuse = {
      userAllowOther = true;
    };
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryFlavor = "gnome3";
    };
    gpaste.enable = true;
    iotop.enable = true;
    java.enable = true;
    less.enable = true;
    # nm-applet.enable = true;
    npm.enable = true;
    # ssh = {
    #   forwardX11 = true;
    # };
    traceroute.enable = true;
    vim.defaultEditor = true;
  };

  # List services that you want to enable:

  services = {
    avahi = {
      enable = true;
      nssmdns = true;
      ipv6 = true;
      publish = {
        enable = true;
        addresses = true;
        hinfo = true;
        userServices = true;
        workstation = true;
      };
      openFirewall = true;
    };
    locate ={
      enable = true;
      locate = pkgs.mlocate;
      localuser = null;
      prunePaths = [
        "/tmp"
        "/var/tmp"
        "/var/cache"
        "/var/lock"
        "/var/run"
        "/var/spool"
        "/nix/store"
        "/home/christian/pron"
      ];
    };
    openssh.enable = true;
    unbound = {
      allowedAccess = [
        "127.0.0.0/24"
        "::1"
      ];
      enable = true;
    };
    blueman = {
      enable = true;
    };
    openssh = {
      forwardX11 = true;
    };
    transmission = {
      enable = true;
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).

  nixpkgs.config = {
    packageOverrides = super: let self = super.pkgs; in {
      xsaneGimp = super.pkgs.xsane.override { gimpSupport = true; };
    };

    allowUnfree = true;
    allowBroken = true;
  };

  security = {
    pki = {
      certificateFiles = [
        "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
      ];
      certificates = [
        (builtins.readFile ./79dachboden5.cer)
      ];
    };
    sudo.wheelNeedsPassword = false;
  };
  system.stateVersion = "20.09"; # Did you read the comment?
}
