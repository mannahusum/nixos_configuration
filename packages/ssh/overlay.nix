final: _prev: let
  version = "20260716";
  keys_to_file = name: keys:
    builtins.toFile name (
      builtins.concatStringsSep "\n" keys
    );

  al_pgp_key = final.fetchurl {
    url = "https://keys.openpgp.org/vks/v1/by-email/christian@wudika.de";
    hash = "sha256-lQ5GtUi848zbCG1bd+w5nD4AqSvr4qyXrLz8rv3QQP8=";
  };

  al_public_keys_file = with final;
    stdenv.mkDerivation {
      name = "ssh_public_keys-${version}";

      unpackPhase = ''
        cp "$src" armored_public_key
      '';

      src = al_pgp_key;

      buildInputs = [
        gnupg
      ];

      buildPhase = ''
        declare -a TO_DELETE=()
        trap cleanup_on_exit EXIT

        cleanup_on_exit() {
            for tempfile in "''${TO_DELETE[@]}"; do
              if [[ -n "''${tempfile}" ]]; then
                echo "deleting tempfile ''${tempfile}"
                rm -rf "''${tempfile}"
              fi
            done
        }

        delete_and_forget() {
            local filename="''${1}"; shift
            local i

            echo "deleting and forgetting ''${tempfile}"
            rm -rf "''${filename}"

            for i in "''${!TO_DELETE[@]}"; do
            if [[ ''${TO_DELETE[i]} = "$filename" ]]; then
                unset 'TO_DELETE[i]'
            fi
            done
        }

        line_to_keyid() {
            local line="''${1}"; shift
            local keypattern='.*/([0-9A-Z]+) '

            [[ $line =~ $keypattern ]]
            echo -n "''${BASH_REMATCH[1]}"
        }

        extract_ssh_public_keys() {
            local gpg_public_key="''${1}"; shift
            local ssh_keys="''${1}"; shift
            local keyline
            local gpgdir
            gpgdir="$(mktemp -d)"
            TO_DELETE+=("''${gpgdir}")

            touch "''${ssh_keys}"
            gpg --quiet --homedir "''${gpgdir}" --import "''${gpg_public_key}"
            while read -r keyline; do
            gpg --homedir "''${gpgdir}" --export-ssh-key "$(line_to_keyid "''${keyline}")!" >>"''${ssh_keys}"
            done < <(gpg --homedir "''${gpgdir}" --list-public-keys --keyid-format LONG | grep '\[A\]')
            delete_and_forget "''${gpgdir}"
        }

        main() {
            extract_ssh_public_keys armored_public_key authorized_keys
        }

        # Add current authorized_keys in order to avoid to be locked out
        cat >authorized_keys <<EOF
        ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6YIlElgTY8NR9PS6m7umTu23TIWd8LJ1r50wMhVjDHDqsa4SvW4uTjTL3MEi7myNSv5oL6kaUrybigFV2nJt+gUwD+3u18FRD+0zQQEhn4f2PSjgEK+htGMkqRSbvVNdLrjbtf783eTRkUn4ICG/4+kgT1eN7qydBrn/soX2pihVNMOMIUH34DKTXDKKXPhSIoquuI87a+j00mz7Sa0eWycGZfx7bqRf5RJvhfwBg5DMh+isCn3n3ueFuc95GFeF7eXzjtnGux/uxj2wtuJ2u/J8tV2vf/CG6a/xMLSmUXpL7ZemOAeEOuX8bEAFCsN3I6hXMfHxmq9wey/ll2C/V cardno:10_162_754
        ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCzzNzYW3kYH+fHz/rSXD6A6UAd3eCQq3dilaLgPfax5qXBK7i+c+mhVUrWqDCpy7qC7ZIkvEcqDqnGT+cCASzEj1yrY5GFq+/Sw5zKo1wYa70wZUoVccFDxsn/GJ0Lp2HGZITz4/hnRdBE0HFDwIobVmhl5/8jQjGQV2DKMT6tBCljOkn5Fs2YMAu19fhyxnlQcxd5A98QFRJlCOzCt2JRVjiYZptjucNMS3zDZH6ucDtuYlFje9ocQycrFPs5vXKbNe1PjdInfYHPzF94ou5tGkelW+6Q8dpheziioUOarLBN6ABdPKqOcOWiDHe7cgwKtj6m+SF223chW5C8WrbJ cardno:16_049_902
        EOF

        main
      '';

      installPhase = ''
        cp authorized_keys $out
      '';
    };

  al_public_keys = builtins.filter (string: string != "") (final.lib.splitString "\n" (builtins.readFile al_public_keys_file.out));
  gitlab_ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPLbfzdFD93S+Hme28WQKS67btUan8GNCR/FQAfg86is vm-templates@gitlab";

  testing_ssh_keys = with final;
    stdenv.mkDerivation {
      name = "ssh_testing_keys-${version}";

      unpackPhase = ":";

      buildInputs = [
        openssh
      ];

      buildPhase = ''
        ssh-keygen -q -t ed25519 -b 512 -f ssh-key -N ""
      '';

      installPhase = ''
        mkdir -p $out
        cp ssh-key{,.pub} $out
      '';
    };

  admin_ssh_public_keys = al_public_keys;

  testing_ssh_public_key = builtins.readFile (testing_ssh_keys.out + "/ssh-key.pub");

  testing_all_ssh_public_keys =
    admin_ssh_public_keys
    ++ [testing_ssh_public_key gitlab_ssh_public_key];
in {
  inherit al_pgp_key al_public_keys testing_ssh_public_key testing_all_ssh_public_keys admin_ssh_public_keys;

  al_public_keyfile = keys_to_file al_public_keys;
  admins_ssh_public_keyfile = keys_to_file admin_ssh_public_keys;

  testing_ssh_public_keyfile = testing_ssh_keys.out + "/ssh-key.pub";
  testing_ssh_private_key = builtins.readFile (testing_ssh_keys.out + "/ssh-key");
  testing_ssh_private_keyfile = testing_ssh_keys.out + "/ssh-key";
  testing_all_ssh_public_keysfile = keys_to_file testing_all_ssh_public_keys;

  admins_ssh_public_key_hcl_file = builtins.toFile "authorized_keys.pkrvars.hcl" (
    "ssh_additional_public_keys = [\n\""
    + (builtins.concatStringsSep "\",\n\"" admin_ssh_public_keys)
    + "\"\n]\n"
  );
}
