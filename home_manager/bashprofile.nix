{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.ca.bash;

  dagEntryToShell = key: script:
    concatStringsSep "\n" [
      "# ${key}"
      script
    ];
in {
  options = {
    ca.bash = {
      enable = mkEnableOption "Generate bash configuration";

      extraProfile = mkOption {
        type = hm.types.dagOf types.str;
        default = [];
        example = literalExpression ''
          {
            configDir = "mkdir $HOME/.config";
            nvimConfigDir = lib.hm.dag.entryAfter [ "configDir" ] "mkdir $HOME/.config/nvim";
          };
        '';
        description = "DAG of commands to be added to the bash profile";
      };
    };
  };

  config = mkIf cfg.enable {
    programs = {
      eza.enable = true;
      bash = {
        enable = true;
        historyControl = ["ignorespace"];
        initExtra = ''
          GPG_TTY=$(tty)
        '';
      };

      direnv = {
        enable = true;
        nix-direnv.enable = true;
      };

      powerline-go = {
        enable = true;
      };

      bash.profileExtra = let
        sortedProfileExtras = hm.dag.topoSort cfg.extraProfile;
        sortedProfileExtrasStr = builtins.toJSON sortedProfileExtras;
        profileExtras =
          sortedProfileExtras.result or (abort "Dependency cycle in bash profile: ${sortedProfileExtrasStr}");
      in
        concatStringsSep "\n\n" (map (entry: dagEntryToShell entry.name entry.data) profileExtras);
    };
  };
}
