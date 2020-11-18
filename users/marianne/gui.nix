{ pkgs, users, nix, services, security, programs, ... }: 
  let
    home-manager = builtins.fetchGit {
      url = "https://github.com/rycee/home-manager.git";
      rev = "63f299b3347aea183fc5088e4d6c4a193b334a41";
      ref = "release-20.09";
    };
  in
  {
    imports =
      [
        (import "${home-manager}/nixos")
        ./console.nix
      ];


    home-manager.users.marianne = {
      home.stateVersion = "20.09";
      home.username = "marianne";

      # home.packages = with pkgs; [
      #   gnome3
      # ];

      xsession = {
        enable = true;
        windowManager.command = "${pkgs.gnome3.gnome-session}/bin/gnome-session";
      };

      programs = {
        home-manager = {
          enable = true;
        };
      };
    };
  }

