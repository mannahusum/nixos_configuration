{
  description = "Machine definition for computers at home";

  inputs = {
    home-config = {
      url = "path:myhomeconfig.nix";
      flake = false;
    };
    nixos-hardware.url = "github:8bitbuddhist/nixos-hardware?ref=surface-rust-target-spec-fix";
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-25.11";
    };
    nixpkgs-makemkv = {
      url = "github:NixOS/nixpkgs/ed9d88e5ee5dd5aa71c807c6f60c9c5cf58d3676";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
    nix-flake-tests.url = "github:antifuchs/nix-flake-tests";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-luks-yk = {
      url = "github:akkesm/nixos-luks-yk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:/Mic92/sops-nix";
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
    disko,
    flake-utils,
    home-config,
    home-manager,
    lanzaboote,
    nix-darwin,
    nix-flake-tests,
    nixos-anywhere,
    nixos-hardware,
    nixos-luks-yk,
    nixpkgs,
    nixpkgs-makemkv,
    self,
    sops-nix,
    ...
  } @ inputs: let
    overlays = [
      (import ./packages/ssh/overlay.nix)
      (import ./packages/darwin/overlay.nix)
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
              if pkgs.lib.strings.hasSuffix "-linux" system
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
              inherit home-manager nixos-luks-yk nixos-anywhere nixpkgs overlays self sops-nix system;
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
              inherit home-manager nixos-luks-yk nixpkgs nixpkgs-makemkv overlays sops-nix system;
            };
          };
        ulpia = let
          system = "x86_64-linux";
        in
          inputs.nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [
              ./computers/ulpia/configuration.nix
              ./computers/ulpia/hardware-configuration.nix
              ./computers/ulpia/sops.nix
              disko.nixosModules.disko
              lanzaboote.nixosModules.lanzaboote
              {
                boot = {
                  bootspec.enable = true;
                  loader.systemd-boot.enable = inputs.nixpkgs.lib.mkForce false;
                  lanzaboote = {
                    enable = true;
                  };
                };
              }
            ];
            specialArgs = {
              inherit home-manager nixos-luks-yk nixpkgs nixpkgs-makemkv overlays sops-nix system;
            };
          };
        alexandretta = let
          system = "x86_64-linux";
        in
          inputs.nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [
              ./computers/alexandretta/configuration.nix
              ./computers/alexandretta/hardware-configuration.nix
              ./computers/alexandretta/sops.nix
              disko.nixosModules.disko
              #lanzaboote.nixosModules.lanzaboote
              {
                boot = {
                  # bootspec.enable = true;
                  # loader.systemd-boot.enable = inputs.nixpkgs.lib.mkForce false;
                  loader.systemd-boot.enable = true;
                  # lanzaboote = {
                  #   enable = true;
                  #   pkiBundle = "/run/secrets/secureboot";
                  # };
                };
              }
            ];
            specialArgs = {
              inherit home-manager nixos-luks-yk nixpkgs nixpkgs-makemkv overlays sops-nix system;
            };
          };
        odysseus = let
          system = "x86_64-linux";
        in
          inputs.nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [
              ./computers/odysseus/configuration.nix
              nixos-hardware.nixosModules.microsoft-surface-pro-intel
              disko.nixosModules.disko
              lanzaboote.nixosModules.lanzaboote
              {
                boot = {
                  bootspec.enable = true;
                  loader.systemd-boot.enable = inputs.nixpkgs.lib.mkForce false;
                  lanzaboote = {
                    enable = true;
                    pkiBundle = "/var/lib/sbctl";
                  };
                };
              }
            ];
            specialArgs = {
              inherit home-manager nixos-luks-yk nixpkgs nixpkgs-makemkv overlays sops-nix system;
            };
          };
        ulysses = let
          system = "x86_64-linux";
        in
          inputs.nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [
              ./computers/ulysses/configuration.nix
              nixos-hardware.nixosModules.microsoft-surface-pro-intel
              disko.nixosModules.disko
              lanzaboote.nixosModules.lanzaboote
              {
                boot = {
                  bootspec.enable = true;
                  loader.systemd-boot.enable = inputs.nixpkgs.lib.mkForce false;
                  lanzaboote = {
                    enable = true;
                  };
                };
              }
            ];
            specialArgs = {
              inherit home-manager nixos-luks-yk nixpkgs nixpkgs-makemkv overlays sops-nix system;
            };
          };
        axum = let
          system = "aarch64-linux";
        in inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./computers/axum/configuration.nix
            nixos-hardware.nixosModules.raspberry-pi-4
            disko.nixosModules.disko
            lanzaboote.nixosModules.lanzaboote
            # {
            #   boot = {
            #     bootspec.enable = true;
            #     loader.systemd-boot.enable = inputs.nixpkgs.lib.mkForce = false;
            #     lanzaboote = {
            #       enable = true;
            #     };
            #   };
            # }
          ];
          specialArgs = {
            inherit home-manager nixos-luks-yk nixpkgs nixpkgs-makemkv overlays sops-nix system;
          };
        };
      };

      darwinConfigurations."mini" = nix-darwin.lib.darwinSystem {
        modules = [
          ./computers/mini/configuration.nix
        ];
        specialArgs = {
          inherit home-manager self overlays;
          system = "aarch64-darwin";
        };
      };
    };
}
