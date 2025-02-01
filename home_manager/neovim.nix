{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.ca.neovim;

  vimrc_stuff = pkgs.fetchFromGitHub {
    owner = "mannahusum";
    repo = "vimrc_stuff";
    rev = "7d94f761e37b66254a6de3be09e2aaecd751e448";
    hash = "sha256-wMVsdG5jq/rvrC/Ikzg927mAo+S+C3yLqMsSt8MF5KA=";
    leaveDotGit = true;
  };

  spell = {
    fr = {
      utf-8 = {
        dictionary = pkgs.fetchurl {
          url = "https://ftp.nluug.nl/pub/vim/runtime/spell/fr.utf-8.spl";
          sha256 = "abfb9702b98d887c175ace58f1ab39733dc08d03b674d914f56344ef86e63b61";
        };

        suggestions = pkgs.fetchurl {
          url = "https://ftp.nluug.nl/pub/vim/runtime/spell/fr.utf-8.sug";
          sha256 = "0294bc32b42c90bbb286a89e23ca3773b7ef50eff1ab523b1513d6a25c6b3f58";
        };
      };

      latin1 = {
        dictionary = pkgs.fetchurl {
          url = "https://ftp.nluug.nl/pub/vim/runtime/spell/fr.latin1.spl";
          sha256 = "086ccda0891594c93eab143aa83ffbbd25d013c1b82866bbb48bb1cb788cc2ff";
        };

        suggestions = pkgs.fetchurl {
          url = "https://ftp.nluug.nl/pub/vim/runtime/spell/fr.latin1.sug";
          sha256 = "5cb2c97901b9ca81bf765532099c0329e2223c139baa764058822debd2e0d22a";
        };
      };
    };
    de = {
      utf-8 = {
        dictionary = pkgs.fetchurl {
          url = "https://ftp.nluug.nl/pub/vim/runtime/spell/de.utf-8.spl";
          hash = "sha256-c8cQfqM5hWzb6SHeuSpFk5xN5uucByYdobndGfaDo9E=";
        };

        suggestions = pkgs.fetchurl {
          url = "https://ftp.nluug.nl/pub/vim/runtime/spell/de.utf-8.sug";
          sha256 = "0294bc32b42c90bbb286a89e23ca3773b7ef50eff1ab523b1513d6a25c6b3f58";
        };
      };

      latin1 = {
        dictionary = pkgs.fetchurl {
          url = "https://ftp.nluug.nl/pub/vim/runtime/spell/de.latin1.spl";
          sha256 = "sha256-iedU+cMNolKlNP6aSzTeDV/72DlnuqWccb/yb/UAw0I=";
        };

        suggestions = pkgs.fetchurl {
          url = "https://ftp.nluug.nl/pub/vim/runtime/spell/de.latin1.sug";
          sha256 = "5cb2c97901b9ca81bf765532099c0329e2223c139baa764058822debd2e0d22a";
        };
      };
    };
  };

  spell_attrs_to_cp = configHome:
    builtins.foldl' (y: x: x + y) "" (
      map (
        lang:
          builtins.foldl' (x: y: x + y) "" (
            map (
              encoding:
                (
                  if (builtins.hasAttr "dictionary" spell."${lang}"."${encoding}")
                  then let
                    path = spell."${lang}"."${encoding}".dictionary;
                  in "cp ${path} ${configHome}/nvim/spell/${lang}.${encoding}.spl\n"
                  else ""
                )
                + (
                  if (builtins.hasAttr "suggestions" spell."${lang}"."${encoding}")
                  then let
                    path = spell."${lang}"."${encoding}".dictionary;
                  in "cp ${path} ${configHome}/nvim/spell/${lang}.${encoding}.sug\n"
                  else ""
                )
            ) (builtins.attrNames spell."${lang}")
          )
      ) (builtins.attrNames spell)
    );
in {
  imports = [
    ./bashprofile.nix
    ./cagpg.nix
  ];

  options = {
    ca.neovim = {
      enable = mkEnableOption "Generate Neovim configuration";
      backgroundservice = mkEnableOption "Run a nvim listening in the background";
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services = {
      nvim = mkIf cfg.backgroundservice {
        Unit = {
          Description = "An nvim running in background for remote forwarding and profit";
          Documentation = ["https://neovim.io/doc/user" "man:nvim(1)"];
        };

        Install = {
          WantedBy = [ "default.target" ];
        };

        Service = {
          Type = "exec";
          ExitType = "main";

          ExecStart = "+${config.programs.neovim.finalPackage}/bin/nvim --headless --listen %t/nvim-local";
          Restart = "always";
        };
      };
    };

    programs.neovim = {
      enable = true;
      withPython3 = true;
      withNodeJs = true;
      defaultEditor = true;

      extraPackages = with pkgs; [
        git
        bash
        direnv
        ripgrep
      ];
      extraPython3Packages = ps:
        with ps; [
          pynvim
          msgpack
          black
          simple-websocket-server
          python-slugify
        ];
    };

    xdg.configFile."neovide/config.toml" = {
      enable = true;
      executable = false;
      text = ''
        fork = false
        neovim-bin = "${config.programs.neovim.finalPackage}/bin/nvim"
        tabs = false
        title-hidden = true
        wsl = false

        [font]
        size = 8.0
      '';
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
            let g:SimplenotePassword = trim(system("${pkgs.pass.out}/bin/pass simplenote/christian@wudika.de | ${pkgs.coreutils.out}/bin/head -n 1"))

            let g:github_user = trim(system("${pkgs.pass.out}/bin/pass github-gist | ${pkgs.gnugrep.out}/bin/grep user: | cut -b 6-"))
            let g:gist_token = trim(system("${pkgs.pass.out}/bin/pass github-gist | ${pkgs.coreutils.out}/bin/head -n 1"))
            let g:gitlab_api_keys = {
            \ 'gitlab.itiv.kit.edu': trim(system("${pkgs.pass.out}/bin/pass gitlab.itivk.it.edu/vimcanixos | ${pkgs.coreutils.out}/bin/head -n 1"))
            \ }
        endif
        let g:powerShellPath ="${pkgs.powershell.out}/bin/pwsh"
        let g:bashLSPPath = "${pkgs.nodePackages.bash-language-server.out}/bin/bash-language-server"
        let g:vimtex_viewer_zathura = "${pkgs.zathura.out}/bin/zathura"
        let g:vimtex_view_automatic = 1
        let g:vimtex_compiler_method = "latexmk"
        let g:vimtex_compiler_latexmk_engines = {
                \ '_'                : "",
                \ 'pdflatex'         : '-pdf',
                \ 'dvipdfex'         : '-pdfdvi',
                \ 'lualatex'         : '-lualatex',
                \ 'xelatex'          : '-xelatex',
                \ 'context (pdftex)' : '-pdf -pdflatex=texexec',
                \ 'context (luatex)' : '-pdf -pdflatex=context',
                \ }
        let g:cmakePath = "${pkgs.cmake-format.out}/bin/cmake-format"
        let g:gist_clip_command = "${pkgs.xclip.out}/bin/xclip -selection primary"
        let g:nilPath = "${pkgs.nil.out}/bin/nil"
        let g:openscadlspPath = "${pkgs.openscad-lsp.out}/bin/openscad-lsp"
        let g:alejandraPath = "${pkgs.alejandra.out}/bin/alejandra"
        let g:clangdPath = "${pkgs.clang-tools.out}/bin/clangd"
        let g:pylintPath = "${pkgs.pylint.out}/bin/pylint"
        let g:ctagsPath = "${pkgs.universal-ctags.out}/bin/ctags"
        let g:coc_node_path = "${pkgs.nodejs.out}/bin/node"
      '';
    };

    ca.bash.enable = true;
    ca.bash.extraProfile.downloadVimConfiguration = hm.dag.entryAfter ["gpgForwardedSockets"] ''
      if [ ! -e ${config.xdg.configHome}/nvim ]; then
          mkdir -p ${config.xdg.configHome}
          cp -R "${vimrc_stuff}" "${config.xdg.configHome}/nvim"
          chmod -R u+rw "${config.xdg.configHome}/nvim"
          mkdir -p "${config.xdg.configHome}/nvim/spell"
          ${spell_attrs_to_cp "${config.xdg.configHome}"}
          ${config.programs.neovim.finalPackage}/bin/nvim +"call dein#install()" +qall
      fi
    '';
  };
}
