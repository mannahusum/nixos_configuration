{ pkgs, lib, config, ... }:
with lib;

let
  get_password_command = account: "${pkgs.pass.out}/bin/pass \"${account.passpath}\"";
in let
  contactHome = "${config.xdg.cacheHome}/contacts";
  calendarHome = "${config.xdg.cacheHome}/calendars";
  maildirs = "${config.home.homeDirectory}/Maildir";

  wudika = {
    name = "WuDiKa";
    email = "christian@wudika.de";
    folders = {
      inbox = "Inbox";
      sent = "Inbox/Sent Messages";
      trash = "Inbox/Trash";
      drafts = "Inbox/Drafts";
    };
    url = "https://ssl.wudika.de/owncloud/remote.php/dav/";
    username = "christian@wudika.de";
    passpath = "wudika.de";
  };

  markomannia = {
    name = "Markomannia";
    email = "sigma@fl-markomannia.de";
    url= "https://www.fl-markomannia.de/egroupware/groupdav.php";
    username = "sigma";
    passpath = "fl-markomannia.de";
    read_only = true;
  };

  yahoo = {
    name = "yahoo";
    email = "manshufude@yahoo.com";
    folders = {
      inbox = "Inbox";
      sent = "Sent";
      trash = "Trash";
      drafts = "Draft";
    };
    username = "manshufude@yahoo.com";
    passpath = "EmailApp/manshufude@yahoo.com";
  };

  mailboxesConfigFile = account: "neomutt/${toLower account.name}-mailboxes.sh";

  maildirhead = account: "${maildirs}/${toLower account.name}/";

  specialMailbox = account: name: subdir: ''
    if [ -d "${maildirhead account}/${subdir}" ]; then
      echo -n " '${name}' '+${subdir}'"
      findargs+="\( -path \"./${subdir}/cur\" -prune \) -o "
    fi
  '';

  findmailboxes = account: ''
    #!${pkgs.bash.out}/bin/bash

    shopt -s extglob

    if [ ! -d "${maildirhead account}" ]; then
      echo "Maildir '${maildirhead account}' not found!" 1>&2
      exit 1
    fi

    echo -n named-mailboxes

    ${optionalString (account.folders.inbox != null && account.folders.inbox != "") (specialMailbox account (toLower account.name) account.folders.inbox)}
    ${optionalString (account.folders.drafts != null && account.folders.drafts != "") (specialMailbox account ((toLower account.name) + "  Entwürfe") account.folders.drafts)}
    ${optionalString (account.folders.sent != null && account.folders.sent != "") (specialMailbox account ((toLower account.name) + "  Gesendet") account.folders.sent)}
    ${optionalString (account.folders.trash != null && account.folders.trash != "") (specialMailbox account ((toLower account.name) + "  Papierkorb") account.folders.trash)}

    pushd "${maildirhead account}" 2>&1 >/dev/null
      findargs+="-type d -name cur -print"
      {
        eval find . $findargs | while read directory; do
          maildir="''${directory%%/cur}"
          echo "''${maildir##./}"
        done
      } | sort -s | while read shortmaildir; do
        name="''${shortmaildir//+([^\/])\//  }"
        echo -n " '$name' '+''${shortmaildir}'"
      done
    popd 2>&1 >/dev/null
  '';

  get_password_vdirsyncer = account: ''"command", "'' + (get_password_command account);
  vdirsyncer_get_readonly = account: if (builtins.hasAttr "read_only" account && isBool account.read_only && account.read_only) then "read_only = true" else "";

  vdirsyncer_kontakte = account: ''
      [pair ${account.name}_Kontakte]
      a = "${toLower account.name}_kontakte_local"
      b = "${toLower account.name}_kontakte_remote"
      collections = ["from a", "from b"]
      metadata = ["displayname"]
      conflict_resolution = "b wins"

      [storage ${toLower account.name}_kontakte_local]
      type = "filesystem"
      path = "${contactHome}/${toLower account.name}/"
      fileext = ".vcf"

      [storage ${toLower account.name}_kontakte_remote]
      type = "carddav"
      url = "${account.url}"
      username = "${account.username}"
      password.fetch = [ ${get_password_vdirsyncer account} ]
      ${vdirsyncer_get_readonly account}

  '';

  vdirsyncer_kalender = account: ''
      [pair ${account.name}_Kalender]
      a = "${toLower account.name}_calendar_local"
      b = "${toLower account.name}_calendar_remote"
      collections = ["from a", "from b"]
      metadata = ["displayname", "color"]
      conflict_resolution = "b wins"

      [storage ${toLower account.name}_calendar_local]
      type = "filesystem"
      path = "${calendarHome}/${toLower account.name}/"
      fileext = ".ics"

      [storage ${toLower account.name}_calendar_remote]
      type = "caldav"
      url = "${account.url}"
      username = "${account.username}"
      password.fetch = [ ${get_password_vdirsyncer account} ]
      ${vdirsyncer_get_readonly account}

  '';
in
{

  xdg.configFile = {
    "${mailboxesConfigFile wudika}" = {
      executable = true;
      text = findmailboxes wudika;
    };
    "${mailboxesConfigFile yahoo}" = {
      executable = true;
      text = findmailboxes yahoo;
    };
    "neomutt/address-provider/mu" = {
      executable = true;
      text = ''
        #!${pkgs.bash.out}/bin/bash

        mu cfind --format=mutt-ab "$@"
      '';
    };
    "vdirsyncer/config".text = ''
      [general]
      status_path = "${config.xdg.cacheHome}/vdirsyncer/status/"

    '' + vdirsyncer_kontakte wudika + vdirsyncer_kontakte markomannia + vdirsyncer_kalender wudika + vdirsyncer_kalender markomannia + ''
      [pair Todoist_Aufgaben]
      a = "todoist_tasks_local"
      b = "todoist_tasks_remote"
      collections = null
      conflict_resolution = "b wins"

      [storage todoist_tasks_local]
      type = "filesystem"
      path = "${calendarHome}/todoist/"
      fileext = ".ics"

      [storage todoist_tasks_remote]
      type = "http"
      url = "https://ext.todoist.com/Export/icalTodoist?user_id=1586158&ical_token=2fda2cb38f63b48171e9011be82cd4f2a6c578989a621a1bda12c237d4e16782&r_factor=6938"
    '';

    "khard/khard.conf".text =''
      [addressbooks]
      [[wudika]]
      path = ${config.xdg.cacheHome}/contacts/wudika/Contacts/
      [[markomannia]]
      path = ${config.xdg.cacheHome}/contacts/markomannia/addressbook/


      [general]
      debug = no
      default_actions = list
      editor = ${pkgs.vimHugeX.out}/bin/vim
      merge_editor = ${pkgs.vimHugeX.out}/bin/vimdiff

      [contact table]
      display = first_name
      group_by_addressbook = no
      reverse = no
      show_nicknames = yes
      show_uids = no
      sort = last_name

      [vcard]
      private_objects = Jabber, Skype, Twitter
      preferred_version = 3.0
      search_in_source_files = no
      skip_unparsable = yes
    '';
  };

  accounts.email.accounts = {
    "googlemail" = {
      realName = "Christian Albertsen";
      address = "mannahusum@googlemail.com";
      flavor = "gmail.com";
      gpg = {
        signByDefault = true;
      };
      imap = {
        host = "imap.gmail.com";
        tls.enable = true;
      };

      lieer = {
        enable = true;
        dropNonExistingLabels = true;
        notmuchSetupWarning = true;
        replaceSlashWithDot = true;
        sync = {
          enable = true;
        };
      };

      passwordCommand = "${pkgs.coreutils.out}/bin/false";
      smtp = {
        host = "smtp.gmail.com";
        tls.enable = true;
      };
      neomutt = {
        extraConfig = ''
          set smtp_url = "smtps://mannahusum@smtp.gmail.com:587"
        '';
      };
      notmuch.enable = true;
      signature = {
        showSignature = "append";
        text = ''
          Mit freundlichen Grüßen,
            Christian Albertsen <${wudika.email}>
        '';
      };
    };

    "wudika" = {
      realName = "Christian Albertsen";
      address = "${wudika.email}";
      userName = "${wudika.email}";
      aliases = [ "sigma@fl-markomannia.de" ];

      passwordCommand = get_password_command wudika;
      gpg = {
        signByDefault = true;
        key = "48E40D6E619CE1E2336A6DE46E5663473DF0E5AF";
      };
      imap = {
        host = "ssl.wudika.de";
        tls.enable = true;
      };
      msmtp.enable = true;
      mbsync = {
        create = "both";
        expunge = "both";
        enable = true;
        remove = "both";
      };
      smtp = {
        host = "ssl.wudika.de";
        port = 25;
        tls.useStartTls = true;
      };
      folders = wudika.folders;
      neomutt = {
        enable = true;
        extraConfig = ''
          source ${config.xdg.configHome}/${mailboxesConfigFile wudika}|
        '';
      };
      notmuch.enable = true;
      primary = true;
    };

    "yahoo" = {
      realName = "Christian Albertsen";
      address = "${yahoo.email}";
      userName = "${yahoo.email}";
      passwordCommand = get_password_command yahoo;
      gpg = {
        signByDefault = true;
      };
      imap = {
        host = "imap.mail.yahoo.com";
        tls.enable = true;
      };
      msmtp.enable = true;
      mbsync = {
        create = "maildir";
        expunge = "both";
        enable = true;
        remove = "maildir";
      };
      smtp = {
        host= "smtp.mail.yahoo.com";
        port = 587;
        tls.enable = true;
      };
      neomutt = {
        enable = true;
        extraConfig = ''
          source ${config.xdg.configHome}/${mailboxesConfigFile yahoo}|
        '';
      };
      notmuch.enable = true;
    };
  };


  nixpkgs.overlays = [
    (self: super:
      let
        ncursesToSlang = replacement: package: if hasPrefix "ncurses-" package.name then replacement else package;
      in {
        emaillua = super.lua.withPackages(ps: with ps; [ luasql-sqlite3 luautf8 ]);
        neomutt = super.neomutt.overrideAttrs (oldAttrs: rec {
          version="20210205";
          buildInputs = (map (ncursesToSlang self.slang) oldAttrs.buildInputs) ++ [ self.emaillua ];
          configureFlags = oldAttrs.configureFlags ++ [
            "--with-slang=${self.slang.dev}"
            "--with-ui=slang"
            "--lua"
            "--with-lua=${self.emaillua}"
          ];
        });
      }
    )
  ];
  home.packages = with pkgs; [
    khard
    emaillua
    mblaze
    mu
    neomutt
    notmuch
    notmuch-mutt
    offlineimap
    openssl
    # vdirsyncerStable
  ];

  programs = {
    msmtp.enable = true;
    lieer.enable = true;
    notmuch.enable = true;
    mbsync.enable = true;
    neomutt = {
      enable = true;
      sort = "date-received";
      editor = "${pkgs.vimHugeX.out}/bin/vim";
      binds = [
        {
          map = [ "editor" ];
          key = "<Tab>";
          action = "complete-query";
        }
        {
          map = [ "index" ];
          key = "\\Cu";
          action = "sidebar-first";
        }
        {
          map = [ "index" ];
          key = "\\Co";
          action = "sidebar-last";
        }
        {
          map = [ "index" ];
          key = "\\Cw";
          action = "sidebar-page-down";
        }
        {
          map = [ "index" ];
          key = "\\Cx";
          action = "sidebar-page-up";
        }
        {
          map = [ "index" ];
          key = "\\Ca";
          action = "sidebar-next";
        }
        {
          map = [ "index" ];
          key = "\\Cl";
          action = "sidebar-prev";
        }
        {
          map = [ "index" ];
          key = "\\Cp";
          action = "sidebar-open";
        }
        {
          map = [ "index" ];
          key = "\\Cä";
          action = "sidebar-toggle-virtual";
        }
      ];
      sidebar = {
        enable = true;
      };
      vimKeys = true;
      extraConfig = ''
        source ${pkgs.neomutt.out}/share/doc/neomutt/samples/gpg.rc
        set query_command = "${config.xdg.configHome}/neomutt/address-provider/mu %s"
        set arrow_cursor
        set autoedit
        set noconfirmappend
        set copy=yes
        set edit_headers
        set index_format="%4C %Z %{%m/%d} %-15.15F (%4c) %s"
        set help
        set include
        set nomark_old
        set move=no
        set pager_index_lines=6
        set noprompt_after
        set read_inc=25
        set reply_to
        set reverse_name
        set nosave_empty
        set tilde
        set nouse_domain

        set autocrypt
        set autocrypt_dir = "${config.xdg.cacheHome}/neomutt/autocrypt"
        set crypt_autosign
        set crypt_autopgp
        set header_cache = "${config.xdg.cacheHome}/neomutt/headers"

        set nm_default_uri = "notmuch://${maildirs}"
      '';
    };
  };

  services = {
    lieer.enable = true;
    mbsync.enable = true;
  };

  #TODO: Import gpg-key into autocrypt keyring
}
