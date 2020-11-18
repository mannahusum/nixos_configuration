#!/bin/sh

set -e
set -u
set +x

# Configuration
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
INSTALL_DEVICE="/dev/disk/by-id/ata-TS512GMTS430S_F417990005"
declare -a MIRROR_DEVICES=( \
  "/dev/disk/by-id/ata-ST2000LM003_HN-M201RAD_S377J9AG900498" \
  "/dev/disk/by-id/ata-ST2000LM015-2E8174_WCC2LAF1"\
)
BOOT_PARTITION_SIZE=3
SWAP_PARTITION_SIZE=64
LIBVIRT_PARTITION_SIZE=512
SYSTEM_POOL_NAME=manna_ssd
STORAGE_POOL_NAME=manna_spin
LIBVIRT_POOL_NAME=libvirt
declare -A KEYS=(
  [Boot]=$(mktemp -p /dev/shm)
  [Swap]=$(mktemp -p /dev/shm)
  [Zfs]=$(mktemp -p /dev/shm)
)
KEYS_DIR="/etc/keys"
INSTALL_DIR="/mnt/nixos"
NIX_VERSION=20.03
PASSPHRASE_FILE="${DIR}/passphrase.txt"
TRUE=$(which true)
CRYPT_BOOT_DEV=mannassdboot
CRYPT_SWAP_DEV=mannassdswap
CRYPT_BOOTBACKUP_DEV=mannaspinboot

# # Check for nixos dependencies:

[ -d /nix ] || curl https://nixos.org/nix/install | sh

if ! which nix-env; then
  if [ -f $HOME/.nix-profile/etc/profile.d/nix.sh ] ; then
    $HOME/.nix-profile/etc/profile.d/nix.sh
  else
    echo "Unable to find nix environment. Giving up"
  fi
fi

if ! which parted; then
  nix-env -iA nixos.parted
fi

echo
echo "Initializing"
echo

get_keyfile_name() {
  usage=$1; shift

  echo "keyfile${usage}.bin"
}

get_keyfile_location() {
  usage=$1; shift

  echo "$KEYS_DIR/$(get_keyfile_name ${usage})"
}

get_bootpartition() {
  device=$1; shift

  echo -n "${device}-part3"
}

get_efipartition() {
  device=$1; shift

  echo -n "${device}-part2"
}

get_uuid() {
  partition=$1; shift
  sudo blkid --match-tag UUID --output value ${partition}
}

swapPartition="${INSTALL_DEVICE}-part4"
rootPartition="${INSTALL_DEVICE}-part5"

echo
echo "Creating keys"
echo

dd if=/dev/urandom of=${KEYS[Boot]} bs=1024 count=4 >/dev/null 2>&1
dd if=/dev/urandom of=${KEYS[Swap]} bs=1024 count=4 >/dev/null 2>&1
dd if=/dev/urandom of=${KEYS[Zfs]} bs=32 count=1 >/dev/null 2>&1
for key in ${KEYS[@]}; do
  chmod 666 $key
done

echo
echo "Cleaning up"
echo

remove_boot() {
  mountpoint=$1; shift
  cryptname=$1; shift
  device=$1; shift

  bootPartition="$(get_bootpartition ${device})"

  sudo umount "${INSTALL_DIR}${mountpoint}/efi" || ${TRUE}
  sudo umount "${INSTALL_DIR}${mountpoint}" || ${TRUE}
  sudo cryptsetup close $cryptname || ${TRUE}
  if [ -e "${bootPartition}" ]; then
    sudo dd if=/dev/zero of=${bootPartition} bs=2M count=10 >/dev/null
fi

}

sudo swapoff "/dev/mapper/${CRYPT_SWAP_DEV}" || ${TRUE}
sudo cryptsetup close "${CRYPT_SWAP_DEV}" || ${TRUE}
backupbootcount=0
for mirror in "${MIRROR_DEVICES[@]}"; do
  remove_boot \
    "/boot${backupbootcount}" \
    "${CRYPT_BOOTBACKUP_DEV}${backupbootcount}" \
    "${mirror}"
  backupbootcount=$(expr $backupbootcount + 1)
done
remove_boot /boot "$CRYPT_BOOT_DEV" "${INSTALL_DEVICE}"
sudo umount "${INSTALL_DIR}/home" || ${TRUE}
sudo umount "${INSTALL_DIR}" || ${TRUE}


for pool in "${SYSTEM_POOL_NAME}" "${LIBVIRT_POOL_NAME}" "${STORAGE_POOL_NAME}"; do
  sudo zpool destroy "${pool}" || ${TRUE}
done
# sudo -- sgdisk --zap-all ${INSTALL_DEVICE}
for mirror in "${INSTALL_DEVICE}" "${MIRROR_DEVICES[@]}"; do
  sudo sgdisk --zap-all ${mirror}
  sudo dd if=/dev/zero of=${mirror} bs=2M count=10 >/dev/null
done


echo
echo "Partitioning.."
echo

sudo sgdisk \
  -n1:+:+2M -c 1:grub -t 1:ef02 -A 1:set:2 \
  -n2:+:+512M -c 2:efi -t 2:ef00 \
  -n3:+:+${BOOT_PARTITION_SIZE}G -c 3:boot -t 3:8300 \
  -n4:+:+${SWAP_PARTITION_SIZE}G -c 4:swap -t 4:8300 \
  -n5:+:- -c 5:system -t 5:8300 \
  ${INSTALL_DEVICE} >/dev/null

sectors_in_system=$(sudo LANG=C sgdisk -i5 ${INSTALL_DEVICE} | grep -i size | cut -d' ' -f3)

for mirror in "${MIRROR_DEVICES[@]}"; do
  sudo sgdisk \
    -n1:+:+2M -c 1:grub -t 1:ef02 -A 1:set:2 \
    -n2:+:+512M -c 2:efi -t 2:ef00 \
    -n3:+:+${BOOT_PARTITION_SIZE}G -c 3:boot -t 3:8300 \
    -n5:+:+${sectors_in_system} -c 5:system -t 5:8300 \
    -n6:+:- -c 6:storage -t 6:8300 \
    ${mirror} >/dev/null
done

sleep 3

echo
echo "Formatting.."
echo

if [[ "${#MIRROR_DEVICES[@]}" > 0 ]]; then
  system_zpool_devices="mirror ${rootPartition} ${MIRROR_DEVICES[@]/%/-part5}"
else
  system_zpool_devices="${rootPartition}"
fi

sudo zpool create \
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
  "${SYSTEM_POOL_NAME}" \
  ${system_zpool_devices}

# Reserve some diskspace for copy-on-write if disk is full
sudo zfs create \
  -o refreservation=1G \
  -o mountpoint=none \
  "${SYSTEM_POOL_NAME}/reserved"

make_storage_mounts() {
  pool=$1; shift

  sudo zfs create \
    -o mountpoint=legacy \
    -o canmount=noauto \
    "${pool}/home"


  sudo zfs create \
    -o canmount=off \
    -o mountpoint=none \
    "${pool}/Virtualisation"

  sudo zfs create \
    -o canmount=off \
    -o mountpoint=none \
    "${pool}/Virtualisation/LXD"

  sudo zfs create \
    -o canmount=off \
    -o mountpoint=none \
    "${pool}/Virtualisation/docker"

  sudo zfs create \
    -V "${LIBVIRT_PARTITION_SIZE}GB" \
    -b "$(getconf PAGESIZE)" \
    -o compression=zle \
    -o logbias=throughput \
    -o sync=always \
    -o primarycache=metadata \
    -o secondarycache=none \
    "${pool}/Virtualisation/libvirt"

  sudo zpool create \
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
}

if [[ "${#MIRROR_DEVICES[@]}" > 0 ]]; then
  sudo zpool create \
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
    "${STORAGE_POOL_NAME}" \
    mirror ${MIRROR_DEVICES[@]/%/-part6}

  sudo zfs create \
    -o refreservation=1G \
    -o mountpoint=none \
    "${STORAGE_POOL_NAME}/reserved"

  make_storage_mounts "${STORAGE_POOL_NAME}"
else
  make_storage_mounts "${SYSTEM_POOL_NAME}"
fi

sudo zfs create \
  -o canmount=off \
  -o mountpoint=none \
  "${SYSTEM_POOL_NAME}/NixOS"

sudo zfs create \
  -o mountpoint=legacy \
  -o canmount=noauto \
  "${SYSTEM_POOL_NAME}/NixOS/root"



# echo "Installing.."

sudo mkdir -p "${INSTALL_DIR}"

sudo mount -t zfs "${SYSTEM_POOL_NAME}/NixOS/root" "${INSTALL_DIR}"
sudo mkdir "${INSTALL_DIR}/home"
if [[ "${#MIRROR_DEVICES[@]}" > 0 ]]; then
  sudo mount -t zfs "${STORAGE_POOL_NAME}/home" "${INSTALL_DIR}/home"
else
  sudo mount -t zfs "${SYSTEM_POOL_NAME}/home" "${INSTALL_DIR}/home"
fi

make_boot_filesystem() {
  mountpoint=$1; shift
  cryptname=$1; shift
  device=$1; shift

  bootPartition="$(get_bootpartition ${device})"
  efiPartition="$(get_efipartition ${device})"

  sudo mkfs.fat -F 32 "${efiPartition}"

  sudo cryptsetup luksFormat \
    --batch-mode \
    --type luks1 \
    -c aes-xts-plain64 \
    -s 256 \
    --pbkdf pbkdf2 \
    "${bootPartition}" "${KEYS[Boot]}"

  sudo cryptsetup luksAddKey \
    --batch-mode \
    --key-file "${KEYS[Boot]}" \
    --pbkdf pbkdf2 \
    "${bootPartition}" \
    "${PASSPHRASE_FILE}"

  sudo cryptsetup open \
    --type luks \
    --key-file \
    "${KEYS[Boot]}" "${bootPartition}" ${cryptname}

  sudo mkfs.ext4 /dev/mapper/${cryptname}

  sudo mkdir "${INSTALL_DIR}${mountpoint}"
  sudo mount /dev/mapper/${cryptname} "${INSTALL_DIR}${mountpoint}"

  sudo mkdir "${INSTALL_DIR}${mountpoint}/efi"
  sudo mount "${efiPartition}" "${INSTALL_DIR}${mountpoint}/efi"
}

# Copy KeyFiles
sudo mkdir -p "${INSTALL_DIR}${KEYS_DIR}"
for usage in "${!KEYS[@]}"; do
  sudo cp "${KEYS[$usage]}" "${INSTALL_DIR}$(get_keyfile_location $usage)"
done
sudo chmod 000 "${INSTALL_DIR}$KEYS_DIR/"*

make_boot_filesystem \
  /boot \
  "$CRYPT_BOOT_DEV" \
  "${INSTALL_DEVICE}"

for ((backupbootcount=0; backupbootcount<${#MIRROR_DEVICES[@]}; backupbootcount++)); do
  make_boot_filesystem \
    "/boot${backupbootcount}" \
    "${CRYPT_BOOTBACKUP_DEV}${backupbootcount}" \
    "${MIRROR_DEVICES[$backupbootcount]}"
done


# swap
sudo cryptsetup luksFormat \
  --batch-mode \
  --type luks1 \
  -c aes-xts-plain64 \
  -s 256 \
  --pbkdf pbkdf2 \
  "${swapPartition}" "${KEYS[Swap]}"

sudo cryptsetup open \
  --type luks \
  --key-file \
  "${KEYS[Swap]}" "${swapPartition}" ${CRYPT_SWAP_DEV}

sudo mkswap -L swap "/dev/mapper/${CRYPT_SWAP_DEV}"

sudo swapoff -a
sudo -- `which nixos-generate-config` --root "${INSTALL_DIR}"
sudo swapon -a

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
  "$(get_bootpartition ${INSTALL_DEVICE})"
for ((c=0; c<${#MIRROR_DEVICES[@]}; c++)); do
  print_initrd_crypt_boot \
    "${CRYPT_BOOTBACKUP_DEV}$c" \
    $(get_bootpartition ${MIRROR_DEVICES[$c]})
done
cat <<EOF
        };
      };
      loader.grub= {
        devices = [
          "${INSTALL_DEVICE}"
        ]; # or "nodev" for efi only
        mirroredBoots = [
EOF
echo  "${MIRROR_DEVICES[@]}" 1>&2
for ((backupbootcount=0; backupbootcount<${#MIRROR_DEVICES[@]}; backupbootcount++)); do
  mirror=${MIRROR_DEVICES[$backupbootcount]}
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
} | sudo tee "${INSTALL_DIR}/etc/nixos/bootdevice.nix" >/dev/null
for filename in *.nix pkgs 79dachboden5.cer; do
  sudo cp -r "${filename}" "${INSTALL_DIR}/etc/nixos/${filename}"
done

echo "nixos-install"
sudo zfs set keylocation=file:///$(get_keyfile_name Zfs) "${SYSTEM_POOL_NAME}"
if [[ "${#MIRROR_DEVICES[@]}" > 0 ]]; then
  sudo zfs set keylocation=file:///etc/keys/$(get_keyfile_name Zfs) "${STORAGE_POOL_NAME}"
fi
sudo PATH="$PATH" NIX_PATH="$NIX_PATH" $(which nixos-install) --show-trace --no-root-passwd --root "${INSTALL_DIR}"

