{
  config,
  lib,
  overlays,
  pkgs,
  ...
}: let
  cfg = config.casoftware;
in {
  imports = [
  ];

  options.casoftware = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether there are domains to request a certificate for
      '';
    };
    # domains = lib.mkOption {
    #   type = lib.types.listOf lib.types.str;
    #   default = [];
    #   description = ''
    #     Domains for which to request certificates
    #   '';
    # };
  };

  config = lib.mkIf cfg.enable {
    nixpkgs = {
      inherit overlays;
      config = {
        allowUnfreePredicate = pkg:
          builtins.elem (lib.getName pkg) [
            "canon-cups-ufr2"
            "cuda_cccl"
            "cuda_cudart"
            "cuda_nvcc"
            "filebot"
            "google-chrome"
            "libcublas"
            "libcufft"
            "libnpp"
            "makemkv"
            "nrf-command-line-tools"
            "nrf-udev"
            "nvidia-settings"
            "nvidia-x11"
            "segger-jlink"
            "unrar"
          ];
        permittedInsecurePackages = [
          "segger-jlink-qt4-874"
        ];
        segger-jlink.acceptLicense = true;
      };
    };

    programs = {
      bat.enable = true;
      cdemu.enable = true;
      direnv = {
        enableBashIntegration = true;
        nix-direnv.enable = true;
      };
      flashprog.enable = true;
      fuse.enable = true;
      git.enable = true;
      iotop.enable = true;
      java = {
        binfmt = true;
        enable = true;
      };
      less.enable = true;
      minipro.enable = true;
      nix-index = {
        enableBashIntegration = true;
      };
      screen.enable = true;
      tcpdump.enable = true;
      vivid = {
        enable = true;
        theme = "solarized-dark";
      };
      yazi = {
        enable = true;
      };
    };

    environment.systemPackages = with pkgs; [
      psmisc
    ];
  };
}

