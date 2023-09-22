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
    ssh-keys = {
      url = "github:mannahusum/sshkeys_from_gpg_keyserver";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-generators, home-manager, disko, ssh-keys, ...}@inputs: {
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
      hydra = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./computers/hydra/configuration.nix
          ./computers/hydra/hardware-configuration.nix
          disko.nixosModules.disko
        ];
        specialArgs = { inherit ssh-keys; };
      };
    };
  };
}
