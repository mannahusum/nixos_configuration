{
  lib,
  pkgs,
  self,
  ...
}:
{
  imports = [
    # sops-nix.nixosModules.sops
    # ./sops.nix
    # (modulesPath + "/profiles/base.nix")
    # ../../modules/acme.nix
    ../../modules/keyboard.nix
    # ../../modules/sshd.nix
    # ../../modules/saned.nix
    # ../../modules/nginx.nix
    # ../../modules/yubikey.nix
    # ../../modules/system_administration/debug.nix
    # ../../modules/users.nix
    # ./fileshare-classic.nix
    # ./smb-fileserver.nix
  ];

  nixpkgs.overlays = [
    (self: super: {
      neolayout = self.stdenv.mkDerivation {
        pname = "neo-layouts";
        version = "0";
        src = self.fetchurl {
          url = "https://dl.neo-layout.org/neo-layouts.dmg";
          hash = "sha256-4kTXjWHp5EnQuaTyMWshCOwZCImWh7vMmIDRxOUg50U=";
        };
        meta = with lib; {
          description = "Neo is an ergonomic keyboard layout optimized for the German language";
          homepage = "https://neo-layout.org/";
          # license = license.gpl3;
          maintainers = [{
            email = "christian@wudika.de";
            github = "mannahusum";
            githubId = 223651;
            name = "Christian Albertsen";
          }];
          platforms = [
            "x86_64-darwin"
            "aarch64-darwin"
          ];
        };

        nativeBuildInputs = with self; [ _7zz ];

        unpackPhase = ''
          7zz x $src
        '';

        installPhase = ''
          mkdir -p $out
          cp -r neo-layouts.bundle $out/neo-layouts.bundle
        '';
      };
    })
  ];

  system.primaryUser = "christianalbertsen";
  cakeyboard.enable = true;

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    _7zz
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
  # services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Necessary for using flakes on this system.
  nix = {
    buildMachines = [
      {
        hostName = "hydra.fritz.box";
        sshUser = "christian";
        protocol = "ssh";
        systems = ["x86_64-linux" "i686-linux"];
        maxJobs = 4;
        speedFactor = 2;
        supportedFeatures = ["big-parallel" "kvm" "nixos-test"];
      }
    ];
    settings = {
      experimental-features = "nix-command flakes";
      system-features = [ "nixos-test" "apple-virt" ];
    };
    extraOptions = ''
      extra-platforms = x86_64-darwin aarch64-darwin
    '';
    linux-builder = {
      enable = true;
      config = {
        nix.settings.sandbox = false;
        virtualisation = {
          darwin-builder = {
            diskSize = 40 * 1024;
            memorySize = 8 * 1024;
          };
          cores = 6;
        };
      };
      ephemeral = true;
      maxJobs = 4;
      supportedFeatures = [ "kvm" "benchmark" "big-parallel" "nixos-test" ];
    };
  };

  launchd.daemons.linux-builder = {
    serviceConfig = {
      StandardOutPath = "/var/log/darwin-builder.log";
      StandardErrorPath = "/var/log/darwin-builder.log";
    };
  };

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs = {
    zsh.enable = true; # default shell on catalina
    bash.enable = true;
    # fish.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };

  system = {
    # Set Git commit hash for darwin-version.
    configurationRevision = self.rev or self.dirtyRev or null;

    # Used for backwards compatibility, please read the changelog before changing.
    # $ darwin-rebuild changelog
    stateVersion = 6;

    # defaults = {
    #   dock.autohide = true;
    #   dock.mru-spaces = false; # Most Recently Used spaces.
    #   finder.AppleShowAllExtensions = true;
    #   finder.FXPreferredViewStyle = "icnv"; # icon view. Other options are: Nlsv (list), clmv (column), Flwv (cover flow)
    #   screencapture.location = "~/Pictures/screenshots";
    #   screensaver.askForPasswordDelay = 10; # in seconds
    # };
  };

  nixpkgs = {
    # allowUnfree is required to install some packages that are not "free" software.
    config.allowUnfree = true;

    # The platform the configuration will be used on.
    hostPlatform = "aarch64-darwin";
  };
}

