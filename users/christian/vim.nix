{ lib, pkgs, home, ... }:

let

    vimPythonPackages = python-packages: with python-packages; [
      pylint
      pynvim
    ];

    vimPython38 = pkgs.python38Full.withPackages vimPythonPackages;
in {

  programs.git.ignores = [
    "*.swp"
  ];

  home = {
    packages = with pkgs; [ ((
        vimHugeX.overrideAttrs (
          oldAttrs: rec {
            buildInputs = oldAttrs.buildInputs ++ (
              with pythonPackages; [
                black
                jedi
                simple-websocket-server
                python-slugify
              ]
            );
          }
        )
      ).override {
        python = vimPython38;
      })
      solargraph
      xdotool
      shellcheck
    ];

    file.".secret_vimrc" = {
      text = ''
let g:powershellPath = "${pkgs.powershell.out}/bin/pwsh"
let g:bashLSPPath = "${pkgs.nodePackages.bash-language-server.out}/bin/bash-language-server"
let g:pythonPath = "${vimPython38.out}/bin/python"
let g:pylintPath = "${vimPython38.out}/bin/pylint"
let g:SimplenoteUsername = "christian@wudika.de"
let g:SimplenotePassword = trim(system("pass simplenote.com/christian@wudika.de | head -n 1"))
let g:vimtex_viewer_zathura = "${pkgs.zathura}/bin/zathura"
let g:vimtex_view_automatic = 1
let g:vimtex_view_automatic_xwin = 1
let g:vimtex_compiler_method = "latexmk"
let g:vimtex_compiler_latexmk_engines = {
        \ '_'                : ''',
        \ 'pdflatex'         : '-pdf',
        \ 'dvipdfex'         : '-pdfdvi',
        \ 'lualatex'         : '-lualatex',
        \ 'xelatex'          : '-xelatex',
        \ 'context (pdftex)' : '-pdf -pdflatex=texexec',
        \ 'context (luatex)' : '-pdf -pdflatex=context',
        \}

let g:cmakePath = "${pkgs.cmake-format.out}/bin/cmake-format"
let g:github_user = trim(system("pass github-gist | grep user: | cut -b 6-"))
let g:gist_token = trim(system("pass github-gist | head -n 1"))
let g:gist_clip_command = "${pkgs.xclip.out}/bin/xclip -selection primary"
let g:black_virtualenv = "${pkgs.black.out}/"
'';};
    activation.checkoutVimConfig = lib.hm.dag.entryAfter ["installSSHprivateKey"] ''
      vim_changed=""
      if [ ! -x $HOME/.vim ]; then
        $DRY_RUN_CMD git clone $VERBOSE_ARG https://github.com/mannahusum/vimrc_stuff.git $HOME/.vim
        vim_changed=1
      fi
      if [ ! -d $HOME/.vim/black ]; then
        $DRY_RUN_CMD "${vimPython38.out}/bin/python" -m venv "$HOME/.vim/black"
        $DRY_RUN_CMD "$HOME/.vim/black/bin/python3" -m pip install -U pip
        vim_changed=1
      fi
      if [ ! -x $HOME/.vim/black/bin/black ]; then
        $DRY_RUN_CMD "$HOME/.vim/black/bin/python3" -m pip install -U black
      fi
      if [ -n "$vim_changed" ]; then
        ${pkgs.vimHugeX.out}/bin/vim +"call dein#install()" +qall
      fi
    '';
  };

}


