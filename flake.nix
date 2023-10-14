{
  description = "Machine definition for computers at home";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-23.05";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko/v1.1.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.3.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:/Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ssh-keys = {
      url = "github:mannahusum/sshkeys_from_gpg_keyserver";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-generators, home-manager, disko, ssh-keys, lanzaboote, sops-nix, ...}@inputs: {
    homeConfigurations = {
      christian_at_hydra = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [
          ./modules/christian/homeManager.nix
          {
            programs = {
              home-manager.enable = true;
              git.enable = true;
            };
            home = {
              username = "christian";
              homeDirectory = "/home/christian";
              stateVersion = "23.05";
            };
          }
        ];

        extraSpecialArgs = {
          inherit inputs;
        };
      };
    };
    nixosConfigurations = {
      hydra_install = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./computers/hydra/configuration.nix
          ./computers/hydra/hardware-configuration.nix
          disko.nixosModules.disko
          sops-nix.nixosModules.sops
          {
            boot.loader.systemd-boot = {
              enable = true;
              configurationLimit = 10;
              graceful = true;
            };
          }
        ];
        specialArgs = { inherit ssh-keys; };
      };
      hydra_prepare_secureboot = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./computers/hydra/configuration.nix
          ./computers/hydra/hardware-configuration.nix
          disko.nixosModules.disko
          lanzaboote.nixosModules.lanzaboote
          {
            boot.bootspec.enable = true;
            boot.loader.systemd-boot = {
              enable = true;
              configurationLimit = 10;
              graceful = true;
            };
          }
        ];
        specialArgs = { inherit ssh-keys; };
      };
      hydra = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./computers/hydra/configuration.nix
          ./computers/hydra/hardware-configuration.nix
          disko.nixosModules.disko
          lanzaboote.nixosModules.lanzaboote
          {
            boot.bootspec.enable = true;
            boot.loader.systemd-boot.enable = false;
            lanzaboote = {
              enable = true;
              pkiBundle = "/etc/secureboot";
            };
          }
        ];
        specialArgs = { inherit ssh-keys; };
      };
    };
  };
}
