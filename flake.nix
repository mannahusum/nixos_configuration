{
  description = "Machine definition for computers at home";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-24.05";
    };
    nixpkgs-utsushi = {
      url = "github:NixOS/nixpkgs/b0249fdf998d782e1058b0cf3239091e59e393ef";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
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
    nix-flake-tests.url = "github:antifuchs/nix-flake-tests";
    # nixos-generators = {
    #   url = "github:nix-community/nixos-generators";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    nixos-luks-yk = {
      url = "github:akkesm/nixos-luks-yk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-anywhere = {
      url = "github:nix-community/nixos-anywhere";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        disko.follows = "disko";
      };
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-utsushi,
    home-manager,
    disko,
    ssh-keys,
    lanzaboote,
    sops-nix,
    nixos-luks-yk,
    nixos-anywhere,
    nix-flake-tests,
    ...
  } @ inputs: {
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
              stateVersion = "24.05";
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
          ./computers/hydra/sops.nix
          disko.nixosModules.disko
          {
            boot.loader.systemd-boot = {
              enable = true;
              configurationLimit = 10;
              graceful = true;
            };
          }
        ];
        specialArgs = {inherit ssh-keys nixpkgs-utsushi nixpkgs home-manager sops-nix;};
      };
      hydra_prepare_secureboot = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./computers/hydra/configuration.nix
          ./computers/hydra/hardware-configuration.nix
          ./computers/hydra/sops.nix
          disko.nixosModules.disko
          lanzaboote.nixosModules.lanzaboote
          {
            boot = {
              bootspec.enable = true;
              loader.systemd-boot = {
                enable = true;
                configurationLimit = 10;
                graceful = true;
              };
            };
          }
        ];
        specialArgs = {inherit ssh-keys nixpkgs-utsushi nixpkgs home-manager sops-nix;};
      };
      hydra = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./computers/hydra/configuration.nix
          ./computers/hydra/hardware-configuration.nix
          ./computers/hydra/sops.nix
          disko.nixosModules.disko
          lanzaboote.nixosModules.lanzaboote
          {
            boot = {
              bootspec.enable = true;
              loader.systemd-boot.enable = inputs.nixpkgs.lib.mkForce false;
              lanzaboote = {
                enable = true;
                pkiBundle = "/etc/secureboot";
              };
            };
          }
        ];
        specialArgs = {inherit ssh-keys nixpkgs-utsushi nixpkgs home-manager sops-nix;};
      };
    };
    checks."x86_64-linux" = let
      pkgs = nixpkgs.legacyPackages."x86_64-linux";
    in {
      ssh = nix-flake-tests.lib.check {
        inherit pkgs;
        tests = import ./functions/tests/ssh.nix {inherit pkgs;};
      };
    };
    devShells.x86_64-linux.default = let
      pkgs = nixpkgs.legacyPackages.x86_64-linux.extend nixos-luks-yk.overlay;
    in
      pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          alejandra
          statix
          hextorb
          rbtohex
          pbkdf2-sha512
          cryptsetup
          gcc
          openssl
          sops
          yubikey-personalization
          nixos-anywhere.packages.x86_64-linux.nixos-anywhere
        ];
      };
  };
}
