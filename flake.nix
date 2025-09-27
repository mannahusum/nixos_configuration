{
  description = "Machine definition for computers at home";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-25.05";
    };
    nixpkgs-utsushi = {
      url = "github:NixOS/nixpkgs/b0249fdf998d782e1058b0cf3239091e59e393ef";
    };
    nixpkgs-makemkv = {
      url = "github:NixOS/nixpkgs/ed9d88e5ee5dd5aa71c807c6f60c9c5cf58d3676";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko/v1.12.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:/Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flake-tests.url = "github:antifuchs/nix-flake-tests";
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
    nixpkgs-makemkv,
    nix-darwin,
    home-manager,
    disko,
    flake-utils,
    lanzaboote,
    sops-nix,
    nixos-luks-yk,
    nixos-anywhere,
    nix-flake-tests,
    ...
  } @ inputs: let
    overlays = [
      (import ./packages/ssh/overlay.nix)
      nixos-luks-yk.overlay
    ];
    mypkgs = system:
      import inputs.nixpkgs {
        inherit system overlays;
        config.allowUnfreePredicate = pkg:
          builtins.elem (nixpkgs.lib.getName pkg) [
            "google-chrome"
          ];
      };
  in
    flake-utils.lib.eachDefaultSystem (system: {
      homeConfigurations = {
        christian_at_hydra = home-manager.lib.homeManagerConfiguration {
          inherit nixpkgs overlays system;
          modules = [
            ./home-manager/caHomeConfig.nix
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
            forwardTo = "/home/christian/.forwarded-sockets";
            createForwardPath = true;
            withExtraSocket = false;
          };
        };
      };

      checks = let
        pkgs = mypkgs system;
      in {
        ssh = nix-flake-tests.lib.check {
          inherit pkgs;
          tests = import ./functions/tests/ssh.nix {inherit pkgs;};
        };
      };

      devShells.default = let
        pkgs = mypkgs system;
        install_remote = pkgs.writeShellApplication {
          name = "install-remote";
          runtimeInputs = [
            nixos-anywhere.packages."${system}".nixos-anywhere
            pkgs.git
            pkgs.sudo
          ];
          text = ''
            hostname="$1"; shift

            cd "$(git rev-parse --show-toplevel)"
            echo -n Disk Encryption Password:
            read -rs USER_PASSWORD
            nixos-anywhere -f ".#''${hostname}_install" --disk-encryption-keys /tmp/secret.key <(echo -n "''${USER_PASSWORD}") --extra-files "computers/''${hostname}/extra-files" "root@''${hostname}.fritz.box"
          '';
        };
      in
        pkgs.mkShell {
          nativeBuildInputs = with pkgs;
            [
              alejandra
              ansible-lint
              deadnix
              gcc
              git
              git-crypt
              jq
              nixos-anywhere.packages."${system}".nixos-anywhere
              openssl
              powershell
              sops
              ssh-to-age
              statix
              yamlfmt
              yamllint
              yj
              yubikey-personalization
            ]
            ++ (
              if pkgs.lib.strings.hasPrefix "linux-" system
              then [
                hextorb
                rbtohex
                pbkdf2-sha512
                cryptsetup
                install_remote
              ]
              else []
            );
        };
    })
    // {
      nixosConfigurations = {
        hydra = let
          system = "x86_64-linux";
        in
          inputs.nixpkgs.lib.nixosSystem {
            inherit system;
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
            specialArgs = {
              inherit home-manager nixos-luks-yk nixpkgs nixpkgs-utsushi overlays sops-nix system;
            };
          };
        alexandria = let
          system = "x86_64-linux";
        in
          inputs.nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [
              ./computers/alexandria/configuration.nix
              ./computers/alexandria/hardware-configuration.nix
              ./computers/alexandria/sops.nix
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
            specialArgs = {
              inherit home-manager nixos-luks-yk nixpkgs nixpkgs-makemkv nixpkgs-utsushi overlays sops-nix system;
            };
          };
      };

      darwinConfigurations."simple" = nix-darwin.lib.darwinSystem {
        modules = let
          pkgs = mypkgs "aarch64-darwin";
        in [
          ./computers/mini/configuration.nix
        ];
      };
    };
}
