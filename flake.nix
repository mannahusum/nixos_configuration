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
    # nixos-generators = {
    #   url = "github:nix-community/nixos-generators";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    nixos-luks-yk = {
      url = "github:akkesm/nixos-luks-yk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, disko, ssh-keys, lanzaboote, sops-nix, nixos-luks-yk, ...}@inputs: {
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
    nixosConfigurations = let
        sops-config = {
            sops.defaultSopsFile = ./computers/hydra/secrets.yaml;
            sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
            sops.secrets."secureboot/GUID" = {
                path = "/etc/secureboot/GUID";
            };
            sops.secrets."secureboot/db/public" = {
                path = "/etc/secureboot/keys/db/db.pem";
            };
            sops.secrets."secureboot/db/private" = {
                path = "/etc/secureboot/keys/db/db.key";
            };
            sops.secrets."secureboot/KEK/public" = {
                path = "/etc/secureboot/keys/KEK/KEK.pem";
            };
            sops.secrets."secureboot/KEK/private" = {
                path = "/etc/secureboot/keys/KEK/KEK.key";
            };
            sops.secrets."secureboot/PK/public" = {
                path = "/etc/secureboot/keys/PK/PK.pem";
            };
            sops.secrets."secureboot/PK/private" = {
                path = "/etc/secureboot/keys/PK/PK.key";
            };
        };
    in {
      hydra_install = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./computers/hydra/configuration.nix
          ./computers/hydra/hardware-configuration.nix
          disko.nixosModules.disko
          sops-nix.nixosModules.sops
          ({
            boot.loader.systemd-boot = {
              enable = true;
              configurationLimit = 10;
              graceful = true;
            };
          } // sops-config)
        ];
        specialArgs = { inherit ssh-keys; };
      };
      hydra_prepare_secureboot = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./computers/hydra/configuration.nix
          ./computers/hydra/hardware-configuration.nix
          disko.nixosModules.disko
          sops-nix.nixosModules.sops
          lanzaboote.nixosModules.lanzaboote
          ({
            boot.bootspec.enable = true;
            boot.loader.systemd-boot = {
              enable = true;
              configurationLimit = 10;
              graceful = true;
            };
          } // sops-config)
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
          sops-nix.nixosModules.sops
          ({
            boot.bootspec.enable = true;
            boot.loader.systemd-boot.enable = inputs.nixpkgs.lib.mkForce false;
            boot.lanzaboote = {
              enable = true;
              pkiBundle = "/etc/secureboot";
            };
          } // sops-config)
        ];
        specialArgs = { inherit ssh-keys; };
      };
    };
    devShells.x86_64-linux.default = let
      pkgs = nixpkgs.legacyPackages.x86_64-linux.extend(nixos-luks-yk.overlay);
    in pkgs.mkShell {
      nativeBuildInputs = with pkgs;
      [
        hextorb
        rbtohex
        pbkdf2-sha512
        cryptsetup
        gcc
        openssl
        sops
        yubikey-personalization
      ];
    };
  };
}
