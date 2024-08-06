{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.ca.neovim;
in {
  imports = [
    ./bashprofile.nix
    ./cagpg.nix
  ];

  options = {
    ca.neovim = {
      enable = mkEnableOption "Generate Neovim configuration";
    };
  };

  config = mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      withPython3 = true;
      withNodeJs = true;

      extraPython3Packages = ps:
        with ps; [
          pynvim
          msgpack
          black
          simple-websocket-server
          python-slugify
        ];
    };

    home.file.".secret_vimrc" = {
      enable = true;
      executable = false;
      text = ''
        let g:powerShellPath ="${pkgs.powershell.out}/bin/pwsh"
        let g:bashLSPPath = "${pkgs.nodePackages.bash-language-server.out}/bin/bash-language-server"
        let g:vimtex_viewer_zathura = "${pkgs.zathura.out}/bin/zathura"
        let g:vimtex_view_automatic = 1
        let g:vimtex_view_automatic_xwin = 1
        let g:vimtex_compiler_method = "latexmk"
        let g:vimtex_compiler_latexmk_engines = {
                \ '_'                : "",
                \ 'pdflatex'         : '-pdf',
                \ 'dvipdfex'         : '-pdfdvi',
                \ 'lualatex'         : '-lualatex',
                \ 'xelatex'          : '-xelatex',
                \ 'context (pdftex)' : '-pdf -pdflatex=texexec',
                \ 'context (luatex)' : '-pdf -pdflatex=context',
                \}
        let g:cmakePath = "${pkgs.cmake-format.out}/bin/cmake-format"
        let g:gist_clip_command = "${pkgs.xclip.out}/bin/xclip -selection primary"
      '';
    };

    ca.bash.enable = true;
    ca.bash.extraProfile.downloadVimConfiguration = hm.dag.entryAfter ["gpgForwardedSockets"] ''
      if [ ! -e $HOME/.config/nvim ]; then
          mkdir -p $HOME/.config
          if (ssh-add -L | grep ssh >/dev/null); then
              git clone git@github.com:mannahusum/vimrc_stuff.git $HOME/.config/nvim
              ${config.programs.neovim.finalPackage}/bin/nvim +"call dein#install()" +qall
          fi
      fi
    '';
  };
}
