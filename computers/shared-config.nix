{
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/base.nix")
    ./shared-config-combined.nix
    ../modules/gitea.nix
    ../modules/keyboard.nix
    ../modules/networking.nix
    ../modules/nginx.nix
    ../modules/saned.nix
    ../modules/sshd.nix
    ../modules/standard-software.nix
    ../modules/uefi.nix
    ../modules/usermount.nix
    ../modules/users.nix
    ../modules/wayland.nix
    ../modules/xandikos.nix
    ../modules/yubikey.nix
  ];

  config = {
    services.fwupd = {
      enable = true;
    };
    i18n = {
      defaultLocale = "de_DE.UTF-8";
      extraLocaleSettings = {
        LC_COLLATE = "de_DE.UTF-8";
        LC_CTYPE = "de_DE.UTF-8";
      };
    };
    hardware.graphics.enable = true;

    cakeyboard.enable = true;
    canetworking.enable = true;
    casoftware.enable = true;
    casshd.enable = true;
    cauefi.enable = true;
    causermount.enable = true;
    cawayland.enable = true;
    cayubikey.enable = true;

  };
}
