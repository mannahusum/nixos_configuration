{
  pkgs,
  self,
  ...
}:
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

