{
  pkgs,
  environment,
  hardware,
  services,
  security,
  programs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    xorg.xf86inputevdev
    xorg.xf86inputlibinput
    xorg.xf86videointel
    xorg.xf86inputsynaptics
    xorg.xorgserver
    steam
    steam-run-native
  ];

  # Enable sound.
  hardware = {
    pulseaudio = {
      enable = true;
      support32Bit = true;
      daemon.config = {
        avoid-resampling = true;
      };
    };
    opengl = {
      driSupport32Bit = true;
      extraPackages32 = with pkgs.pkgsi686Linux; [
        libva
      ];
    };
  };

  i18n = {
    defaultLocale = "de_DE.UTF-8";
    inputMethod = {
      enabled = "uim";
      uim.toolbar = "gtk-systray";
    };
  };

  # Enable the X11 windowing system.
  services = {
    xserver = {
      enable = true;
      libinput.enable = true;
      layout = "de,de,gr";
      xkbModel = "pc105";
      xkbVariant = "neo,,";
      xkbOptions = ",,";
      windowManager.awesome = {
        enable = true;
        package = pkgs.awesome;
      };
      desktopManager.gnome.enable = true;
      displayManager = {
        defaultSession = "none+awesome";
        autoLogin.enable = false;

        lightdm = {
          enable = true;
          greeter = {
            enable = true;
          };
        };
      };
    };
  };

  security.pam.services.lightdm.enableGnomeKeyring = true;
  programs.seahorse.enable = true;
}
