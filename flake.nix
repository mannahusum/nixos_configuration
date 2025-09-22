{
  description = "Machine definition for computers at home";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-24.11";
    };
    nixpkgs-utsushi = {
      url = "github:NixOS/nixpkgs/b0249fdf998d782e1058b0cf3239091e59e393ef";
    };
    nixpkgs-makemkv = {
      url = "github:NixOS/nixpkgs/ed9d88e5ee5dd5aa71c807c6f60c9c5cf58d3676";
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
    ssh-keys,
    lanzaboote,
    sops-nix,
    nixos-luks-yk,
    nixos-anywhere,
    nix-flake-tests,
    ...
  } @ inputs:
  let 
    mypkgs = system: import inputs.nixpkgs {
      inherit system;
      overlays = [
        (import ./packages/ssh/overlay.nix)
      ];
      config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [
        "google-chrome"
      ];
    };
  in
  flake-utils.lib.eachDefaultSystem (system:
  {
      homeConfigurations = {
        christian_at_hydra = home-manager.lib.homeManagerConfiguration {
          pkgs = (mypkgs system);
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
        pkgs = (mypkgs system);
      in {
        ssh = nix-flake-tests.lib.check {
          inherit pkgs;
          tests = import ./functions/tests/ssh.nix {inherit pkgs;};
        };
      };

      devShells.default = let
        pkgs = (mypkgs system).extend nixos-luks-yk.overlay;
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
        hydra = let
            system = "x86_64-linux";
          in inputs.nixpkgs.lib.nixosSystem {
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
              # mypkgs{
              #   nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [
              #     "google-chrome"
              #   ];
              #   nixpkgs.config.allowUnfree = true;
              #   home-manager.useGlobalPkgs = false;
              #   home-manager.useUserPackages = true;
              # }
            ];
            specialArgs = {inherit ssh-keys nixpkgs-utsushi nixpkgs home-manager sops-nix system;};
        };
        alexandria = let
          system = "x86_64-linux";
        in inputs.nixpkgs.lib.nixosSystem {
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
          specialArgs = {inherit ssh-keys nixpkgs-utsushi nixpkgs-makemkv nixpkgs home-manager sops-nix system;};
        };
      };

      darwinConfigurations."simple" = nix-darwin.lib.darwinSystem {
        modules = let
          pkgs = (mypkgs "aarch64-darwin");
        in [
          {
            # List packages installed in system profile. To search by name, run:
            # $ nix-env -qaP | grep wget
            environment.systemPackages = with pkgs; [
              darwin.xcode
              git
              fzf # Fuzzy finder
              ripgrep # Faster grep
              jq # Command line JSON processor
              yq # Command line YAML processor
              neovim # Vim-fork focused on extensibility and usability
              pandoc # Universal document converter
              python3 # Python 3 programming language
              htop # Interactive process viewer
              tree # Display directories as trees
              jetbrains-mono # JetBrains Mono font
              ffmpeg # Multimedia framework
              alacritty # GPU-accelerated terminal emulator
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
