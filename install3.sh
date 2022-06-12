#!/usr/bin/env bash

# e - script sotsp on error
# u - errot if undefined variable
# o pipefail - script fails if one of piped commands fails
# x - output each line (DEBUG)
set -euo pipefail

declare become="sudo -n"

# declare global variables
declare my_sgdisk

ensure_nix_installed() {
  if [ -d /nix ]; then
    :
  else
    echo "Nix not found. Trying to install…" 1>&2
    if which curl >/dev/null 2>&1; then
      curl https://nixos.org/nix/install | bash
    elif which wget >/dev/null 2>&1; then
      wget -q -O - https://nixos.org/nix/install | bash
    else
      echo "No nix and no way to install it, bailing out"
      exit 2
    fi
  fi
}

ensure_nix_environment() {
  if ! which nix-env >/dev/null 2>&1 ; then
    if [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ] ; then
      "$HOME/.nix-profile/etc/profile.d/nix.sh"
    else
      show_error "Unable to find nix environment. Giving up"
    fi
  fi

  # ensure that the gcroot exists
  nix-env -i bash
  nix_results_root="$(mktemp -p "/nix/var/nix/gcroots/per-user/$USER/" -d)"
  echo "${nix_results_root}"
}

ensure_command_nix() {
  name="${1}"; shift
  package="${1}"; shift
  nix_results_root="${1}"; shift

  if which "${name}" >/dev/null 2>&1 ; then
    which "${name}"
    return
  fi

  nix_pkg_root=${nix_results_root}/${package}
  echo "$(nix-store --add-root "${nix_pkg_root}" -r "$(nix-instantiate '<nixpkgs>' --add-root "${nix_pkg_root}" -A "${package}" )" | head -n 1)/bin/${name}"
}

ensure_sgdisk() {
  local nix_results_root="${1}"; shift

  my_sgdisk=$(ensure_command_nix sgdisk gptfdisk nix_results_root)
  "${my_sgdisk}" --help >/dev/null 2>&1
  return $?
}

partition_single_disk() {
  local disk, boot_partition_size, swap_partition_size, system_size
  disk="${1}"; shift
  boot_partition_size="${1}"; shift
  swap_partition_size="${1}"; shift
  system_size="${1}"; shift

  echo "Partitioning ${disk}"

  "${become}" "${my_sgdisk}" --zap-all "${disk}"

  partcmd="${my_sgdisk} "
  partcmd+="-n1:+:+2M -c 1:grub -t 1:ef02 -A 1:set:2 "
  partcmd+="-n2:+:+512M -c 2:efi -t 2:ef00 "
  partcmd+="-n3:+:+${boot_partition_size}G -c 3:boot -t 3:8300 "
  partcmd+="-n4:+:+${swap_partition_size}G -c 4:swap -t 4:8300 "
  if [ -z "${system_size}" ]; then
    partcmd+="-n5:+:- -c 5:system -t 5:8300 "
  else
    partcmd+="-n5:+:+${system_size} -c 5:system -t 5:8300 "
    partcmd+="-n6:+:- -c 6:storage -t 6:8300 "
  fi
  partcmd+="${disk}"

  eval "$become $partcmd 2>&1 >/dev/null"
}

ensure_commands() {
  local nix_results_root
  nix_results_root=$(ensure_nix_environment)
  ensure_sgdisk nix_results_root
}

mkfs.btrfs -L nixos /dev/vda
mount -o discard,compress=lzo LABEL=nixos /mnt
nixos-generate-config --root /mnt
cp /tmp/configuration.nix /mnt/etc/nixos/configuration.nix
nixos-install && rebootü
