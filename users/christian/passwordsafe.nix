{ pkgs, config, programs, services, fonts, ...}:
let
  password_store_dir =  "${config.home.homeDirectory}/.password-store";
in {
  fonts.fonts = with pkgs; [
    nerdfonts
  ];

  programs = {
    password-store = {
      enable = true;
      settings = {
        PASSWORD_STORE_KEY = "B83B0DAB1E60F747";
        PASSWORD_STORE_DIR = password_store_dir;
      };
    };
    rofi = {
      enable = true;
      font = "FiraCode Nerd Font Mono 10";
      pass = {
        enable = true;
        stores = [
          password_store_dir
        ];
        extraConfig = ''
        URL_field='url'
        USERNAME_field='user'
        AUTOTYPE_field='autotype'
        '';
      };
    };
  };

  services = {
    password-store-sync = {
      enable = true;
      frequency = "*:00:00";
    };
    # pass-secret-service.enable = true;
  };

}
