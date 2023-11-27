{ config, lib, pkgs, ... }:
let
  cfg = config.x11;
in
{
  imports = [
  ];

  options.x11 = {
  };

  config = {
    services.xserver = {
      libinput.enable = true;
      displayManager = {
        defaultSession = "none+awesome";
        lightdm = {
          enable = true;
          greeter = {
            enable = true;
          };
        };
      };
      windowManager.awesome = {
        enable = true;
        package = pkgs.awesome;
      };
    };
    services.xserver = {
      enable = true;
      videoDrivers = [ "amdgpu" ];
    };
    hardware.opengl = {
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        amdvlk
      ];
      extraPackages32 = with pkgs; [
        driversi686Linux.amdvlk
      ];
    };
  };
}
