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
    rev = "14efe9d9d608924081c14f7a2186cbc67bbb55ff";
    hash = "sha256-TUkm/RzpUlXt87aUd+TlSiB6j/EqRoJvf6q/zAmziBM=";
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
    ./neovim/git.nix
    ./neovim/integration.nix
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
          WantedBy = ["default.target"];
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
      withRuby = true;
      withNodeJs = true;
      defaultEditor = true;
      # sideloadInitLua = true;

      initLua = lib.mkMerge [
        # default priority=1000,
        # package.path at priority=200,
        # and this has to be earlier
        (lib.mkOrder 100 ''
          vim.g.mapleader = "ü"
          vim.g.maplocalleader = "ö"
        '')
      ];
      extraConfig = ''
        " German umlaut u
        let mapleader = nr2char(0x00fc, 1)
        " German umlaut o
        let maplocalleader = nr2char(0x00f6, 1)
      '';

      extraPackages = with pkgs; [
        bash
        clang
        direnv
        fd
        jq
        nixpkgs-fmt
        ripgrep
        texliveFull
        tree-sitter
        xdotool
        zathura
      ];

      extraLuaPackages = ps:
        with ps; [
          lua-curl
          mimetypes
          nvim-nio
          xml2lua
        ];

      extraPython3Packages = ps:
        with ps; [
          black
          msgpack
          pynvim
          python-slugify
          rope
          simple-websocket-server
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
        normal = ["Iosevka Nerd Font"]
        size = 12.0
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
            let g:SimplenoteUsername = trim(system("${pkgs.pass.out}/bin/pass simplenote.com 2>/dev/null | ${pkgs.gnugrep.out}/bin/grep user: | cut -b 6-"))
            let g:SimplenotePassword = trim(system("${pkgs.pass.out}/bin/pass simplenote.com 2>/dev/null | ${pkgs.coreutils.out}/bin/head -n 1"))

            let g:github_user = trim(system("${pkgs.pass.out}/bin/pass github/gist 2>/dev/null | ${pkgs.gnugrep.out}/bin/grep user: | cut -b 6-"))
            let g:gist_token = trim(system("${pkgs.pass.out}/bin/pass github/gist 2>/dev/null | ${pkgs.coreutils.out}/bin/head -n 1"))
            let g:gitlab_api_keys = {
            \ 'gitlab.itiv.kit.edu': trim(system("${pkgs.pass.out}/bin/pass kit.edu/gitlab.itiv.kit.edu/vimcanixos 2>/dev/null | ${pkgs.coreutils.out}/bin/head -n 1"))
            \}
            let $TODOIST_API_KEY = trim(system("${pkgs.pass.out}/bin/pass todoist.com/ApiToken 2>/dev/null | ${pkgs.coreutils.out}/bin/head -n 1"))
        endif
        let g:powerShellPath ="${pkgs.powershell.out}/bin/pwsh"
        let g:bashLSPPath = "${pkgs.bash-language-server.out}/bin/bash-language-server"
        let g:vimtex_view_method = "zathura"
        let g:vimtex_view_automatic = 1
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
        let g:gitlabCiLs = "${pkgs.gitlab-ci-ls.out}/bin/gitlab-ci-ls"
        let g:vimtex_compiler_latexmk = {
            \ 'callback' : 1,
            \ 'continuous' : 1,
            \ 'executable' : "${pkgs.texliveFull.out}/bin/latexmk",
            \}
        let g:fugitive_gitlab_domains = ['https://gitlab.itiv.kit.edu/', 'https://gitlab.kit.edu/']
        let g:fugitive_gitea_domains = ['https://gitea.catbertsen.de']
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
