{ pkgs, sound, environment, hardware, services, ... }:
{
  environment.systemPackages = with pkgs; [
    xorg.xf86inputevdev
    xorg.xf86inputlibinput
    xorg.xf86videointel
    xorg.xf86inputsynaptics
    xorg.xorgserver
  ];

  # Enable sound.
  sound.enable = true;
  hardware = {
    pulseaudio = {
      enable = true;
      support32Bit = true;
    };
    opengl = {
      driSupport32Bit = true;
      extraPackages32 = with pkgs.pkgsi686Linux; [
        libva
      ];
    };
    nvidia.prime = {
      sync.enable= true;
      nvidiaBusId = "PCI:1:0:0";
      intelBusId = "PCI:0:2:0";
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
  # services.xserver.enable = true;
  services = {
    xserver = {
      enable = true;
      autorun = false;
      libinput.enable = true;
      # videoDrivers = [ "intel" ];
      # videoDrivers = [ "modesetting" "intel" "nvidia" ];
      videoDrivers = [ "nvidia" ];
      layout = "de,de,gr";
      xkbModel = "pc105";
      xkbVariant = "neo,,";
      xkbOptions = "";
      windowManager.awesome = {
        enable = true;
        package = pkgs.awesome;
      };
      displayManager = {
        defaultSession = "none+awesome";
        lightdm = {
          enable = true;
          autoLogin.enable = false;
          greeter = {
            enable = true;
          };
        };
      };
    };
  };

  systemd.defaultUnit = "graphical.target";
}
