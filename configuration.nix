# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      # ./x11.nix
      # ./xscreensaver.nix
      # ./users.nix
      # ./dropbox.nix
      # ./virtualization.nix
      ./printing.nix
      ./bootdevice.nix
      ./passwords.nix
    ];

  # Use the GRUB 2 boot loader.
  boot = {
    supportedFilesystems = [
      "ntfs"
      "zfs"
    ];
    zfs = {
      enableUnstable = true;
      requestEncryptionCredentials = true;
    };
    initrd = {
      postDeviceCommands = "mount";
      secrets = {
        "/keyfileBoot.bin" = "/boot/keyfileBoot.bin";
        "/keyfileZfs.bin" = "/boot/keyfileZfs.bin";
      };
    };
    loader = {
      grub = {
        enable = true;
        version = 2;
        efiSupport = true;
        enableCryptodisk = true;
      };
      efi.efiSysMountPoint = "/boot/efi";
    };
  };

  networking = {
    hostId = "90c8ec86";
    hostName = "mannahusum"; # Define your hostname.

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
    useDHCP = false;
    interfaces = {
      enp0s25.useDHCP = true;
      wlan0.useDHCP = true;
    };
    networkmanager = {
      dhcp = "dhclient";
      dns = "unbound";
      enable = true;
    };
  };

  # Select internationalisation properties.
  # i18n.defaultLocale = "de_DE.UTF-8";
  console = {
    earlySetup = true;
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
      kbdKeymaps.neo
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
    file
    less
    lesspipe
    # smartmontools
    vim
    wget
  ];

  environment.etc."mdadm.conf".text = ''
    MAILADDR christian@wudika.de
  '';


  # fonts = {
  #   enableDefaultFonts = true;
  #   enableFontDir = true;
  #   enableGhostscriptFonts = true;

  #   fontconfig = {
  #     allowBitmaps = false;
  #     subpixel.rgba = "rgb";
  #   };

  #   fonts = with pkgs; [
  #     corefonts
  #     dina-font
  #     fira-code
  #     fira-code-symbols
  #     hasklig
  #     inconsolata
  #     liberation_ttf
  #     lmodern
  #     mplus-outline-fonts
  #     noto-fonts
  #     noto-fonts-cjk
  #     noto-fonts-emoji
  #     proggyfonts
  #     source-code-pro
  #     symbola
  #     ubuntu_font_family
  #   ];
  # };


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
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
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryFlavor = "gtk2";
    };
    gpaste.enable = true;
    iotop.enable = true;
    java.enable = true;
    less.enable = true;
    nm-applet.enable = true;
    npm.enable = true;
    ssh = {
      forwardX11 = true;
    };
    traceroute.enable = true;
    vim.defaultEditor = true;
  };

  # List services that you want to enable:

  services = {
    avahi = {
      enable = true;
      nssmdns = true;
    };
    openssh.enable = true;
    unbound = {
      allowedAccess = [
        "127.0.0.0/24"
        "::1"
      ];
      enable = true;
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  # services.xserver.enable = true;
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable touchpad support.
  # services.xserver.libinput.enable = true;

  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).

  nixpkgs.config.allowUnfree = true;

  security.pki = {
    certificateFiles = [
      "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
    ];
    certificates = [
      (builtins.readFile ./79dachboden5.cer)
    ];
  };
  system.stateVersion = "20.09"; # Did you read the comment?
}
