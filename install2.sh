#!/usr/bin/env bash

set -e # Exit after a non-zero exit status
# set -u # Treat unset variables as an error when subtituting
set +x # Do not print commands as they are executed

declare hostname="marianne"
declare become="sudo -n"
declare configuration_file="configuration.nix"
declare -i boot_partition_size=3
declare -i swap_partition_size=64
declare -i libvirt_partition_size=0
declare -r CONFIGURATION_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
declare -r GITHUB_USERNAME="mannahusum"
declare git_repository="git@github.com:${GITHUB_USERNAME}/nixos_configuration.git"
declare -r KEYS_DIR="/etc/keys"
declare -r INSTALL_DIR="$(mktemp -p /dev/shm -d)"
# declare -r NIX_VERSION="21.05"
declare -r PASSPHRASE_FILE="${CONFIGURATION_DIRECTORY}/passphrase.txt"
declare -r TRUE=$(which true)
declare -rA KEYS=(
  [Boot]=$(mktemp -p /dev/shm)
  [Swap]=$(mktemp -p /dev/shm)
  [Zfs]=$(mktemp -p /dev/shm)
)
declare -a mirror_devices

get_efipartition() {
  device=$1; shift

  echo -n "$(get_persistent_disk_path "${device}")-part2"
}

get_bootpartition() {
  device=$1; shift

  echo -n "$(get_persistent_disk_path "${device}")-part3"
}

remove_temporary_keyfiles() {
  echo "Removing keys"
  for keyusage in "${!KEYS[@]}"; do
    keyfile="${KEYS["$keyusage"]}"
    rm $keyfile
  done
}

remove_install_dir() {
  echo "Removing installation directory"
  rm -rf ${INSTALL_DIR}
}

export_zpools() {
  echo "Unmounting zpools"
  [ -n "${SYSTEM_POOL_NAME}" ] && \
    ${become} ${my_zpool} export "${SYSTEM_POOL_NAME}" 2>&1 >/dev/null && ${TRUE}
  if mirror_devices_given; then
    ${become} ${my_zpool} export "${STORAGE_POOL_NAME}" 2>&1 >/dev/null && ${TRUE}
  fi
}

destroy_crypto_devices() {
  echo "Destroying crypto devices"

  [ -n "$CRYPT_BOOT_DEV" ] && \
    ${become} ${my_cryptsetup} close "$CRYPT_BOOT_DEV" || ${TRUE}

  for ((backupbootcount=0; backupbootcount<${#mirror_devices[@]}; backupbootcount++)); do
    ${become} ${my_cryptsetup} close "${CRYPT_BOOTBACKUP_DEV}${backupbootcount}" || ${TRUE}
  done

  [ -n "$CRYPT_SWAP_DEV" ] && \
    ${become} ${my_cryptsetup} close "${CRYPT_SWAP_DEV}" || ${TRUE}
}

unmount_boot_partition() {
  mountpoint=$1; shift
  cryptname=$1; shift
  device=$1; shift

  bootPartition="$(get_bootpartition ${device})"

  echo "Unmounting boot ${mountpoint}"
  ${become} umount "${INSTALL_DIR}${mountpoint}/efi" || ${TRUE}
  ${become} umount "${INSTALL_DIR}${mountpoint}" || ${TRUE}
  if [ -e "${bootPartition}" ]; then
    ${become} dd if=/dev/zero of=${bootPartition} bs=2M count=10 >/dev/null
  fi
}

unmount_filesystems() {
  if [ -n "$CRYPT_BOOT_DEV" ]; then
    echo "Unmounting filesystems…"
    unmount_boot_partition \
      /boot \
      "$CRYPT_BOOT_DEV" \
      "${install_device}"
  fi

  for ((backupbootcount=0; backupbootcount<${#mirror_devices[@]}; backupbootcount++)); do
    unmount_boot_partitions \
      "/boot${backupbootcount}" \
      "${CRYPT_BOOTBACKUP_DEV}${backupbootcount}" \
      "${mirror_devices[$BACKUPBOOTCOUNT]}"
  done

  echo "Unmounting /home"
  ${become} umount "${INSTALL_DIR}/home" | ${TRUE}
  echo "Unmounting /"
  ${become} umount "${INSTALL_DIR}" | ${TRUE}

  if [ -n "$CRYPT_SWAP_DEV" ]; then
    echo "Unmounting swap device"
    ${become} ${my_swapoff} "/dev/mapper/${CRYPT_SWAP_DEV}" 2>&1 >/dev/null || ${TRUE}
  fi
}

cleanup() {
  read -p "blubb: " blubb

  unmount_filesystems
  destroy_crypto_devices
  export_zpools
  remove_temporary_keyfiles
  remove_install_dir
}

trap cleanup EXIT

# Name transformations

get_uuid() {
  partition=$1; shift
  ${become} ${my_blkid} --match-tag UUID --output value ${partition}
}


# Flow control

usage() {
cat <<EOF
$0: $0

Install nixos onto the given device

   -h hostname

   -i device
   --install device
       Install with device as the boot and os device

  -m device
  --mirror device
      Add device to the list of mirrors and storage devices

  --bz size
  --boot-partition-size size
    Set boot partition size in GB
EOF
}

get_canonical_disk_path() {
  disk="${1}"; shift

  ${my_lsblk} -no PATH "${disk}" | head -n 1
}

get_kernel_device_name() {
  disk="${1}"; shift

  ${my_lsblk} -no KNAME "${disk}"
}

get_persistent_disk_path() {
  disk="${1}"; shift
  rdisk="$(get_canonical_disk_path "${disk}")"

  [ -b "${disk}" ] || show_error "'${disk}' is not a block device"

  for path in  /dev/disk/by-id/*; do
    link=$(get_canonical_disk_path "${path}");
    if [ "${link}" == "${disk}" ]; then
      echo "${path}";
      return;
    fi;
  done

  [ -n ${DEBUG+x} ] \
    && printf "No persistent path found for device '%s'" "${disk}" 1>&2
  echo "${disk}"
}

show_error() {
  local message="$1"; shift

  echo "${message}"$'\n' 1>&2
  usage

  exit 1
}

ensure_nix_installed() {
  if [ -d /nix ]; then
    :
  else
    echo "Nix not found. Trying to install…" 1>&2
    if which curl 2>&1 >/dev/null; then
      curl https://nixos.org/nix/install | bash
    elif which wget 2>&1 >/dev/null; then
      wget -q -O - https://nixos.org/nix/install | bash
    else
      echo "No nix and no way to install it, bailing out"
      exit 2
    fi
  fi
}

ensure_nix_environment() {
  if ! which nix-env >/dev/null 2>&1 ; then
    if [ -f $HOME/.nix-profile/etc/profile.d/nix.sh ] ; then
      $HOME/.nix-profile/etc/profile.d/nix.sh
    else
      show_error "Unable to find nix environment. Giving up"
    fi
  fi
}

ensure_installation_device() {

  [ -z "${install_device+x}" ] && show_error "No install device given"

  swapPartition="$(get_persistent_disk_path "${install_device}")-part4"
  rootPartition="$(get_persistent_disk_path "${install_device}")-part5"
}

mirror_devices_given() {
  if [ "${#mirror_devices[@]}" -gt 0 ]; then
    return 0
  else
    return 1
  fi
}

ensure_mirror_devices() {
  local device rinstall rdevice duplicate rduplicate

  if mirror_devices_given; then
    rinstall="$(get_canonical_disk_path "${install_device}")"
    for (( currentdevice=0; ${#mirror_devices[@]}-currentdevice; currentdevice++ )); do
      device="${mirror_devices[$currentdevice]}"
      [ -b "${device}" ] || show_error "${device} is not a block device"
      rdevice="$(get_canonical_disk_path "${device}")"
      [ "${rdevice}" = "${rinstall}" ] \
        && show_error "'${device}' and '${install_device}' are the same device given twice"

      if [ $currentdevice -lt ${#mirror_devices[@]} ]; then
        for (( duplicatedevice=currentdevice+1; ${#mirror_devices[@]}-duplicatedevice; duplicatedevice++ )); do
          duplicate="${mirror_devices[$duplicatedevice]}"
          rduplicate="$(get_canonical_disk_path "${duplicate}")"
          [ "${rdevice}" = "${rduplicate}" ] \
            && show_error "'${device}' and '${duplicate}' are the same device given twice"
        done
      fi
    done
  fi
}

ensure_sudo() {
  if [ $(id -u) = 0 ]; then
    become=""
    return
  fi
  if which sudo >/dev/null 2>&1 ; then
    if sudo -n "${TRUE}"; then
      become="sudo -n"
      return
    fi
  fi
  show_error "not user root and no passwordless sudo"
}

ensure_command_nix() {
  name="${1}"; shift
  package="${1}"; shift

  if which "${name}" >/dev/null 2>&1 ; then
    which ${name}
    return
  fi

  echo $(nix-store -r $(nix-instantiate '<nixpkgs>' -A ${package}))/bin/${name}
}

ensure_lsblk() {
  my_lsblk="$(ensure_command_nix lsblk util-linux)"
  "${my_lsblk}" --help >/dev/null 2>&1
  return $?
}

ensure_blkid() {
  my_blkid="$(ensure_command_nix blkid util-linux)"
  "${my_blkid}" --help >/dev/null 2>&1
  return $?
}

ensure_mkfs_fat() {
  my_mkfs_fat="$(ensure_command_nix mkfs.fat dosfsutils)"
  "${my_mkfs_fat}" --help >/dev/null 2>&1
  return $?
}

ensure_mkfs_ext4() {
  my_mkfs_ext4="$(ensure_command_nix mkfs.ext4 e2fsprogs)"
  "${my_mkfs_ext4}" -V >/dev/null 2>&1
  return $?
}

ensure_zpool() {
  my_zpool="$(ensure_command_nix zpool zfs)"
  "${my_zpool}" --help >/dev/null 2>&1
  return $?
}

ensure_zfs() {
  my_zfs="$(ensure_command_nix zfs zfs)"
  "${my_zfs}" --help >/dev/null 2>&1
  return $?
}

ensure_cryptsetup() {
  my_cryptsetup="$(ensure_command_nix cryptsetup cryptsetup)"
  "${my_cryptsetup}" --help >/dev/null 2>&1
  return $?
}

ensure_swapoff() {
  my_swapoff="$(ensure_command_nix swapoff util-linux)"
  "${my_swapoff}" --help >/dev/null 2>&1
  return $?
}

ensure_swapon() {
  my_swapon="$(ensure_command_nix swapon util-linux)"
  "${my_swapon}" --help >/dev/null 2>&1
  return $?
}

ensure_git() {
  my_git="$(ensure_command_nix git git)"
  "${my_git}" --help >/dev/null 2>&1
  return $?
}

ensure_sgdisk() {
  # if which sgdisk >/dev/null 2>&1 ; then
  #   my_sgdisk="$(which sgdisk)"
  #   return 0
  # fi

  # my_sgdisk="$(nix-store -r $(nix-instantiate '<nixpkgs>' -A gptfdisk))/bin/sgdisk"
  my_sgdisk=$(ensure_command_nix sgdisk gptfdisk)
  "${my_sgdisk}" --help >/dev/null 2>&1
  return $?
}

ensure_nixos_install_program() {
  my_nixos_install=$(ensure_command_nix nixos-install nixos-install)
  "${my_nixos_install}" --help >/dev/null 2>&1
  return $?
}

ensure_hostname_valid() {
  [[ "${hostname}" =~ ^[A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9]$ ]] \
    || show_error "invalid hostname: '${hostname}'"
}

ensure_zpool_not_mounted() {
  poolname="$1"; shift

  ${my_zpool} list $poolname >/dev/null 2>&1 && show_error "'${poolname}' is already in use"
  return 0
}

ensure_zpools_not_in_use() {
  ensure_zpool_not_mounted "${SYSTEM_POOL_NAME}"
  if mirror_devices_given; then
    ensure_zpool_not_mounted "${STORAGE_POOL_NAME}"
  fi
}

ensure_github_access() {
  ssh -T git@github.com </dev/null \
    || [[ $? -eq 1 ]]
}

ensure_devices_unused() {
  local device rdevice kdevice usagestring found fstype

  for device in "${install_device}" "${mirror_devices[@]}"; do
    rdevice="$(get_canonical_disk_path "${device}")"

    found="$(mount | grep ${rdevice} 2>&1 >/dev/null; echo $? )"
    if [ "$found" -eq 0 ]; then
      usagestring="$(mount | grep ${rdevice} )"
      show_error "${device} in use:"$'\n'"${usagestring}"
    fi

    for kdevice in $(get_kernel_device_name "${device}"); do
      read usagestring kname fstype < <(${my_lsblk} -lno NAME,KNAME,TYPE "${device}" | egrep -v "part")
      if [ "${fstype}" = "disk" ]; then
        echo "${device} is a whole disk — Should investigate partitions"
        continue
      fi
      if [ "${kname}" = "${kdevice}" ]; then
        show_error "Device ${device} is in use by ${usagestring} of type ${fstype}"
      fi
    done
  done

  #TODO: Check the devices are not part of a zfs
  #TODO: Check for partitions of the device not being used
}

ensure_cryptdevice_names_unused() {
  local name

  for name in "${CRYPT_BOOT_DEV}" "${CRYPT_SWAP_DEV}" "${CRYPT_BOOTBACKUP_DEV}"; do
    if [ -a "${name}" ]; then
      show_error "Cryptdevice ${name} exits"
    fi
  done
}

ensure_is_efi() {
  [ -d /sys/firmware/efi ]
}

check_prequisits() {
  ensure_nix_installed
  ensure_nix_environment

  ensure_git
  ensure_sudo
  ensure_sgdisk
  ensure_lsblk
  ensure_blkid
  ensure_mkfs_fat
  ensure_mkfs_ext4
  ensure_zpool
  ensure_zfs
  ensure_cryptsetup
  ensure_swapoff
  ensure_swapon
  ensure_nixos_install_program

}

check_config() {
  ensure_hostname_valid
  ensure_installation_device
  ensure_mirror_devices

  initialize_devicenames

  ensure_zpools_not_in_use
  ensure_devices_unused
  ensure_cryptdevice_names_unused

  ensure_github_access
  ensure_is_efi
}

show_config() {
  printf "Using '%s' to execute as root\n" "${become}"
  printf "using '%s' for partitioning the disk\n" "${my_sgdisk}"
  printf "Hostname: '%s'\n" "${hostname}"
  printf "Install device: '%s'\n" "${install_device}"
  if mirror_devices_given; then
    echo "Mirror devices:"
    for mirror in "${mirror_devices[@]}"; do
      printf "  '%s'\n" "${mirror}"
    done
  else
    echo "No mirror devices given"
  fi
  printf "boot partition size: %dG\n" "${boot_partition_size}"
  printf "swap partition size: %dG\n" "${swap_partition_size}"
}

initialize_devicenames() {
  SYSTEM_POOL_NAME="${hostname}_ssd"
  STORAGE_POOL_NAME="${hostname}_spin"
  LIBVIRT_POOL_NAME="${hostname}_libvirt"
  CRYPT_BOOT_DEV="${hostname}ssdboot"
  CRYPT_SWAP_DEV="${hostname}ssdswap"
  CRYPT_BOOTBACKUP_DEV="${hostname}spinboot"
}

initialize_keys() {
  echo "Creating keys"

  for key in ${KEYS[@]}; do
    chmod 600 $key
  done
  dd if=/dev/urandom of=${KEYS[Boot]} bs=1024 count=4 >/dev/null 2>&1
  dd if=/dev/urandom of=${KEYS[Swap]} bs=1024 count=4 >/dev/null 2>&1
  dd if=/dev/urandom of=${KEYS[Zfs]} bs=32 count=1 >/dev/null 2>&1
}


partition_single_disk() {
  local disk system_size partcmd
  disk="${1}"; shift
  system_size="${1}"

  echo Partitioning ${disk}

  $become $my_sgdisk --zap-all "${disk}"

  partcmd="${my_sgdisk} "
  partcmd+="-n1:+:+2M -c 1:grub -t 1:ef02 -A 1:set:2 "
  partcmd+="-n2:+:+512M -c 2:efi -t 2:ef00 "
  partcmd+="-n3:+:+${boot_partition_size}G -c 3:boot -t 3:8300 "
  if [ -z "${system_size}" ]; then
    partcmd+="-n4:+:+${swap_partition_size}G -c 4:swap -t 4:8300 "
    partcmd+="-n5:+:- -c 5:system -t 5:8300 "
  else
    partcmd+="-n5:+:+${system_size} -c 5:system -t 5:8300 "
    partcmd+="-n6:+:- -c 6:storage -t 6:8300 "
  fi
  partcmd+="${disk}"

  eval "$become $partcmd 2>&1 >/dev/null"
}

partition_disks() {
  echo
  echo "Partitioning.."
  echo

  partition_single_disk "${install_device}"
  sectors_in_system=$(${become} LANG=C sgdisk -i5 ${install_device} | grep -i size | cut -d' ' -f3)

  for mirror in "${mirror_devices[@]}"; do
    partition_single_disk "${mirror}" "${sectors_in_system}"
  done
}

make_storage_mounts() {
  pool=$1; shift

  ${become} ${my_zfs} create \
    -o mountpoint=legacy \
    -o canmount=noauto \
    "${pool}/home"


  ${become} ${my_zfs} create \
    -o canmount=off \
    -o mountpoint=none \
    "${pool}/Virtualisation"

  ${become} ${my_zfs} create \
    -o canmount=off \
    -o mountpoint=none \
    "${pool}/Virtualisation/LXD"

  ${become} ${my_zfs} create \
    -o canmount=off \
    -o mountpoint=none \
    "${pool}/Virtualisation/docker"

  if [[ $libvirt_partition_size -gt 0 ]]; then
    ${become} ${my_zfs} create \
      -V "${libvirt_partition_size}GB" \
      -b "$(getconf PAGESIZE)" \
      -o compression=zle \
      -o logbias=throughput \
      -o sync=always \
      -o primarycache=metadata \
      -o secondarycache=none \
      "${pool}/Virtualisation/libvirt"

    ${become} ${my_zpool} create \
      -f \
      -O atime=on \
      -O relatime=on \
      -O acltype=posixacl \
      -O xattr=sa \
      -O aclinherit=passthrough \
      -O dnodesize=auto \
      -O normalization=formD \
      -o ashift=12 \
      -O mountpoint=none \
      -O compression=off \
      "${LIBVIRT_POOL_NAME}" \
      "/dev/zvol/${pool}/Virtualisation/libvirt"
    fi
}

create_zpool() {
  local poolname system_zpool_devices
  poolname="${1}"; shift
  system_zpool_devices="${1}"; shift

  ${become} ${my_zpool} create \
    -f \
    -O atime=on \
    -O relatime=on \
    -O acltype=posixacl \
    -O xattr=sa \
    -O aclinherit=passthrough \
    -O dnodesize=auto \
    -O normalization=formD \
    -o ashift=12 \
    -O encryption=on \
    -O keyformat=raw \
    -O "keylocation=file://${KEYS[Zfs]}" \
    -O mountpoint=none \
    -O compression=on \
    "${poolname}" \
    ${system_zpool_devices}

  # Reserve some diskspace for copy-on-write if disk is full
  ${become} ${my_zfs} create \
    -o refreservation=1G \
    -o mountpoint=none \
    "${poolname}/reserved"

}

make_system_mounts() {
  ${become} ${my_zfs} create \
    -o canmount=off \
    -o mountpoint=none \
    "${SYSTEM_POOL_NAME}/NixOS"

  ${become} ${my_zfs} create \
    -o mountpoint=legacy \
    -o canmount=noauto \
    "${SYSTEM_POOL_NAME}/NixOS/root"
}

is_efi_formated() {
  local device="${1}"; shift

  [ "$(${my_blkid} --match-tag TYPE --output value ${device})" == "vfat" ] \
    && [ "$(${my_blkid} --match-tag PARTLABEL --output value ${device})" == "efi" ]
}

format_boot_partitions() {
  device=$1; shift

  bootPartition="$(get_bootpartition ${device})"
  efiPartition="$(get_efipartition ${device})"

  if is_efi_formated "${efiPartition}"; then
    :
  else
    ${become} ${my_mkfs_fat} -F 32 "${efiPartition}"
  fi

  ${become} ${my_cryptsetup} luksFormat \
    --batch-mode \
    --type luks1 \
    -c aes-xts-plain64 \
    -s 256 \
    --pbkdf pbkdf2 \
    "${bootPartition}" "${KEYS[Boot]}"

  ${become} ${my_cryptsetup} luksAddKey \
    --batch-mode \
    --key-file "${KEYS[Boot]}" \
    --pbkdf pbkdf2 \
    "${bootPartition}" \
    "${PASSPHRASE_FILE}"
}

format_swap_partition() {
  # swap
  ${become} ${my_cryptsetup} luksFormat \
    --batch-mode \
    --type luks1 \
    -c aes-xts-plain64 \
    -s 256 \
    --pbkdf pbkdf2 \
    "${swapPartition}" "${KEYS[Swap]}"

}

create_crypto_swap_partition() {
  ${become} ${my_cryptsetup} open \
    --type luks \
    --key-file \
    "${KEYS[Swap]}" "${swapPartition}" ${CRYPT_SWAP_DEV}

  ${become} mkswap -L swap "/dev/mapper/${CRYPT_SWAP_DEV}"
}

create_crypto_boot_device() {
  cryptname=$1; shift
  device=$1; shift

  bootPartition="$(get_bootpartition ${device})"

  ${become} ${my_cryptsetup} open \
    --type luks \
    --key-file \
    "${KEYS[Boot]}" "${bootPartition}" ${cryptname}

  ${become} mkfs.ext4 /dev/mapper/${cryptname}
}

create_crypto_devices() {
  create_crypto_boot_device \
    "$CRYPT_BOOT_DEV" \
    "${install_device}"

  for ((backupbootcount=0; backupbootcount<${#mirror_devices[@]}; backupbootcount++)); do
    create_crypto_boot_device \
      "${CRYPT_BOOTBACKUP_DEV}${backupbootcount}" \
      "${mirror_devices[$BACKUPBOOTCOUNT]}"
  done

  create_crypto_swap_partition
}

format_partitions() {
  local system_zpool_devices

  echo
  echo "Formatting.."
  echo

  if mirror_devices_given; then
    system_zpool_devices="mirror ${rootPartition} ${mirror_devices[@]/%/-part5}"
  else
    system_zpool_devices="${rootPartition}"
  fi

  create_zpool "${SYSTEM_POOL_NAME}" "${system_zpool_devices}"
  if mirror_devices_given; then
    create_zpool "${STORAGE_POOL_NAME}" "mirror ${mirror_devices[@]/%/-part6}"
    make_storage_mounts "${STORAGE_POOL_NAME}"
  else
    make_storage_mounts "${SYSTEM_POOL_NAME}"
  fi
  make_system_mounts

  format_boot_partitions \
    "${install_device}"

  for ((backupbootcount=0; backupbootcount<${#mirror_devices[@]}; backupbootcount++)); do
    format_boot_partitions \
      "${mirror_devices[$BACKUPBOOTCOUNT]}"
  done

  format_swap_partition

  create_crypto_devices
}

mount_boot_partition() {
  mountpoint=$1; shift
  cryptname=$1; shift
  device=$1; shift

  efiPartition="$(get_efipartition ${device})"

  echo "Mounting ${mountpoint}(/efi)"
  ${become} mkdir "${INSTALL_DIR}${mountpoint}"
  ${become} mount /dev/mapper/${cryptname} "${INSTALL_DIR}${mountpoint}"

  ${become} mkdir "${INSTALL_DIR}${mountpoint}/efi"
  ${become} mount "${efiPartition}" "${INSTALL_DIR}${mountpoint}/efi"
}

mount_partitions() {
  echo "Mounting partitions…"

  echo "Mounting /"
  ${become} mount -t zfs "${SYSTEM_POOL_NAME}/NixOS/root" "${INSTALL_DIR}"
  echo "Mounting /home"
  ${become} mkdir "${INSTALL_DIR}/home"
  if mirror_devices_given; then
    ${become} mount -t zfs "${STORAGE_POOL_NAME}/home" "${INSTALL_DIR}/home"
  else
    ${become} mount -t zfs "${SYSTEM_POOL_NAME}/home" "${INSTALL_DIR}/home"
  fi

  mount_boot_partition \
    /boot \
    "$CRYPT_BOOT_DEV" \
    "${install_device}"

  for ((backupbootcount=0; backupbootcount<${#mirror_devices[@]}; backupbootcount++)); do
    mount_boot_partition \
      "/boot${backupbootcount}" \
      "${CRYPT_BOOTBACKUP_DEV}${backupbootcount}" \
      "${mirror_devices[$BACKUPBOOTCOUNT]}"
  done
}

get_keyfile_name() {
  usage=$1; shift

  echo "keyfile${usage}.bin"
}

get_keyfile_location() {
  usage=$1; shift

  echo "$KEYS_DIR/$(get_keyfile_name ${usage})"
}

print_initrd_crypt_boot() {
  devicename=$1; shift
  partition=$1; shift

  cat <<EOF
    "${devicename}" = {
      # preLVM = true;
      keyFile = "/$(get_keyfile_name Boot)";
      allowDiscards = true;
      device = "/dev/disk/by-uuid/$(get_uuid ${partition})";
    };
EOF
}

create_bootdevice_nix() {
{
cat <<EOF
  { boot, swapDevices, ... }:

  {
    boot = {
      initrd = {
        secrets = {
EOF
for usage in "${!KEYS[@]}"; do
cat <<EOF
          "/$(get_keyfile_name $usage)" = "$(get_keyfile_location $usage)";
EOF
done
cat <<EOF
        };
        luks.devices = {
EOF
print_initrd_crypt_boot \
  "${CRYPT_BOOT_DEV}" \
  "$(get_bootpartition ${install_device})"
for ((c=0; c<${#mirror_devices[@]}; c++)); do
  print_initrd_crypt_boot \
    "${CRYPT_BOOTBACKUP_DEV}$c" \
    $(get_bootpartition ${mirror_devices[$c]})
done
cat <<EOF
        };
      };
      loader.grub= {
        devices = [
          "${install_device}"
        ]; # or "nodev" for efi only
        mirroredBoots = [
EOF
echo  "${mirror_devices[@]}" 1>&2
for ((backupbootcount=0; backupbootcount<${#mirror_devices[@]}; backupbootcount++)); do
  mirror=${mirror_devices[$backupbootcount]}
  cat <<EOF
          {
            devices = [
              "${mirror}"
            ];
            path = "/boot$backupbootcount";
            efiBootloaderId="NixOS-backup-$backupbootcount";
            efiSysMountPoint="/boot$backupbootcount/efi";
          }

EOF
done

cat <<EOF
        ];
      };
    };
    swapDevices = [
      {
        device = "/dev/disk/by-uuid/$(get_uuid /dev/mapper/${CRYPT_SWAP_DEV})";
        encrypted = {
          enable = true;
          keyFile = "/$(get_keyfile_name Swap)";
          label = "${CRYPT_SWAP_DEV}";
          blkDev = "/dev/disk/by-uuid/$(get_uuid ${swapPartition})";
        };
      }
    ];
  }
EOF
} | ${become} tee "${INSTALL_DIR}/etc/nixos/bootdevice.nix" >/dev/null
}

clone_configuration() {
  ${become} ${my_git} clone ${git_repository} "${INSTALL_DIR}/etc/nixos/"
}

set_zfs_keyfile_locations() {
  ${become} ${my_zfs} set keylocation=file:///$(get_keyfile_name Zfs) "${SYSTEM_POOL_NAME}"
  if mirror_devices_given; then
    ${become} ${my_zfs} set keylocation=file:///etc/keys/$(get_keyfile_name Zfs) "${STORAGE_POOL_NAME}"
  fi
}

copy_crypto_keys() {
  ${become} mkdir -p "${INSTALL_DIR}${KEYS_DIR}"
  for keyusage in "${!KEYS[@]}"; do
    keyfile="${KEYS[$keyusage]}"
    echo ${become} cp "${keyfile}" "${INSTALL_DIR}$(get_keyfile_location $keyusage)"
    ${become} cp "${keyfile}" "${INSTALL_DIR}$(get_keyfile_location $keyusage)"
  done
}

install_nixos() {
  local build
  local found
  local local_config="${INSTALL_DIR}/etc/nixos/$(basename ${configuration_file})"
  copy_crypto_keys
  clone_configuration
  ${become} -- `which nixos-generate-config` --root "${INSTALL_DIR}"
  create_bootdevice_nix
  set_zfs_keyfile_locations
  if [ -f /etc/nixos/passwords.nix ]; then
    ${become} cp /etc/nixos/passwords.nix "${INSTALL_DIR}/etc/nixos/passwords.nix"
  fi
  pushd "${INSTALL_DIR}/etc/nixos/" 2>&1 >/dev/null
    [ -a "${configuration_file}" ] && found=1
  popd 2>&1 >/dev/null
  ${become} cp "${configuration_file}" "${local_config}"
  build=$(nix-build -I nixos-config=${local_config} '<nixpkgs/nixos>' -A system --no-out-link)
  ${become} ${my_nixos_install} \
    --system ${build} \
    --show-trace \
    --no-root-passwd \
    --root "${INSTALL_DIR}"
}

main() {

  while [[ $# -gt 0 ]]; do
    key="${1}"; shift
    case "${key}" in
      -h|--hostname)
        hostname="$1"; shift
        ;;
      -i|--install)
        [ -n "${install_device+x}" ] \
          && show_error "Only one install device may be given"
        [ -z "${1+x}" ] && show_error "no install device given"
        # install_device="$(get_persistent_disk_path "${1}")"; shift
        [ -b "${1}" ] || show_error "'$1' is not a block device"
        install_device="${1}"; shift
        ;;
      -m|--mirror)
        [ -z "${1+x}" ] && show_error "no mirror device given"
        [ -b "${1}" ] || show_error "'$1' is not a block device"
        mirror_devices+=( "$1" ); shift
        ;;
      --bz|--boot-partition-size )
        [ -z "${1+x}" ] && show_error "no boot_partition_size given"
        boot_partition_size="${1}"; shift
        ;;
      --sz|--swap-partition-size)
        [ -z "${1+x}" ] && show_error "no swap_partition_size given"
        swap_partition_size="${1}"; shift
        ;;
      -g|--git-repo)
        [ -z "${1+x}" ] && show_error "no GIT repository given"
        git_repository="${1}"; shift
        ;;
      -c|--config)
        [ -z "${1+x}" ] && show_error "no configuration.nix given"
        configuration_file="${1}"; shift
        ;;
      *)
        show_error "Invalid option: '%s'\n" "${key}"
        ;;
    esac
  done

  check_prequisits
  check_config
  show_config
  initialize_keys
  partition_disks
  sleep 3 # wait for partition tables to be reread
  format_partitions
  mount_partitions
  install_nixos
}

if [ "$0" == "${BASH_SOURCE[0]}" ] ; then
  main "$@"
fi

