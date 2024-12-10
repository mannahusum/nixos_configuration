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
      defaultEditor = true;

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
        silent call system("echo 'test' | ${pkgs.gnupg}/bin/gpg2 --encrypt --recipient christian@wudika.de | ${pkgs.gnupg}/bin/gpg2 --decrypt -o /dev/null")
        if v:shell_error != 0
          echom "Can't decrypt passwords. Keys won't be available"
        else
          let g:SimplenoteUsername = "christian@wudika.de"
          let g:SimplenotePassword = trim(system("${pkgs.pass.out}/bin/pass simplenote/christian@wudika.de | ${pkgs.coreutils.out}/bin/head -1"))
          let g:github_user = trim(system("${pkgs.pass.out}/bin/pass github-gist | ${pkgs.gnugrep.out}/bin/grep user: | cut -b 6-"))
          let g:gist_token = trim(system("${pkgs.pass.out}/bin/pass github-gist | ${pkgs.coreutils.out}/bin/head -n 1"))
        endif
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
        let g:nilPath = "${pkgs.nil.out}/bin/nil"
        let g:openscadlspPath = "${pkgs.openscad-lsp.out}/bin/openscad-lsp"
        let g:alejandraPath = "${pkgs.alejandra.out}/bin/alejandra"
        let g:clangdPath = "${pkgs.clang-tools}/bin/clangd"
        let g:pylintPath = "${pkgs.pylint.out}/bin/pylint"
        let g:ctagsPath = "${pkgs.universal-ctags}/bin/ctags"
      '';
    };

    ca.bash.enable = true;
    ca.bash.extraProfile.downloadVimConfiguration = hm.dag.entryAfter ["gpgForwardedSockets"] ''
      if [ ! -e $HOME/.config/nvim ]; then
          mkdir -p $HOME/.config
          if (${pkgs.openssh.out}/bin/ssh-add -L | ${pkgs.gnugrep.out}/bin/grep ssh >/dev/null); then
              ${pkgs.git.out}/bin/git clone git@github.com:mannahusum/vimrc_stuff.git $HOME/.config/nvim
              ${config.programs.neovim.finalPackage}/bin/nvim +"call dein#install()" +qall
          fi
      fi
    '';
  };
}
