{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.ca.git;
in {
  imports = [
  ];

  options = {
    ca.git = {
      enable = mkEnableOption "Generate Git configuration";
    };
  };

  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      settings.user = {
        name = "Christian Albertsen";
        email = "christian@wudika.de";
      };
    };
    home.packages = with pkgs; [
      git-filter-repo
    ]
  };
}
