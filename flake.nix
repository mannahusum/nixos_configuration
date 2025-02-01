{
  description = "Machine definition for computers at home";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-24.11";
    };
    nixpkgs-utsushi = {
      url = "github:NixOS/nixpkgs/b0249fdf998d782e1058b0cf3239091e59e393ef";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko/v1.1.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
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
    nix-darwin,
    home-manager,
    disko,
    flake-utils,
    ssh-keys,
    lanzaboote,
    sops-nix,
    nixos-luks-yk,
    nixos-anywhere,
    nix-flake-tests,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (system: {
      homeConfigurations = {
        christian_at_hydra = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."${system}";
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

      checks = let
        pkgs = nixpkgs.legacyPackages."${system}";
      in {
        ssh = nix-flake-tests.lib.check {
          inherit pkgs;
          tests = import ./functions/tests/ssh.nix {inherit pkgs;};
        };
      };

      devShells.default = let
        pkgs = nixpkgs.legacyPackages."${system}".extend nixos-luks-yk.overlay;
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
              statix
              gcc
              openssl
              ssh-to-age
              sops
              yubikey-personalization
              nixos-anywhere.packages."${system}".nixos-anywhere
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
        alexandria = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
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
          specialArgs = {inherit ssh-keys nixpkgs-utsushi nixpkgs home-manager sops-nix;};
        };
      };

      darwinConfigurations."simple" = nix-darwin.lib.darwinSystem {
        modules = let
          pkgs = import nixpkgs {
            system = "aarch64-darwin";
            config.allowUnfree = true;
          };
        in [
          {
            # List packages installed in system profile. To search by name, run:
            # $ nix-env -qaP | grep wget
            environment.systemPackages = [
              pkgs.darwin.xcode
              pkgs.git
              pkgs.fzf # Fuzzy finder
              pkgs.ripgrep # Faster grep
              pkgs.jq # Command line JSON processor
              pkgs.yq # Command line YAML processor
              pkgs.neovim # Vim-fork focused on extensibility and usability
              pkgs.pandoc # Universal document converter
              pkgs.python3 # Python 3 programming language
              pkgs.htop # Interactive process viewer
              pkgs.tree # Display directories as trees
              pkgs.jetbrains-mono # JetBrains Mono font
              pkgs.ffmpeg # Multimedia framework
              pkgs.alacritty # GPU-accelerated terminal emulator
            ];

            # Auto upgrade nix package and the daemon service.
            services.nix-daemon.enable = true;
            # nix.package = pkgs.nix;

            # Necessary for using flakes on this system.
            nix = {
              settings.experimental-features = "nix-command flakes";
              extraOptions = ''
                extra-platforms = x86_64-darwin aarch64-darwin
              '';
              linux-builder.enable = true;
            };

            # Create /etc/zshrc that loads the nix-darwin environment.
            programs = {
              zsh.enable = true; # default shell on catalina
              bash.enable = true;
              # fish.enable = true;

              direnv.enable = true;
              direnv.nix-direnv.enable = true;
            };

            system = {
              # Set Git commit hash for darwin-version.
              configurationRevision = self.rev or self.dirtyRev or null;

              # Used for backwards compatibility, please read the changelog before changing.
              # $ darwin-rebuild changelog
              stateVersion = 4;

              defaults = {
                dock.autohide = true;
                dock.mru-spaces = false; # Most Recently Used spaces.
                finder.AppleShowAllExtensions = true;
                finder.FXPreferredViewStyle = "icnv"; # icon view. Other options are: Nlsv (list), clmv (column), Flwv (cover flow)
                screencapture.location = "~/Pictures/screenshots";
                screensaver.askForPasswordDelay = 10; # in seconds
              };
            };

            nixpkgs = {
              # allowUnfree is required to install some packages that are not "free" software.
              config.allowUnfree = true;

              # The platform the configuration will be used on.
              hostPlatform = "aarch64-darwin";
            };
          }
        ];
      };
    };
}
