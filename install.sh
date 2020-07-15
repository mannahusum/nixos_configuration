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
# BOOT_PARTITION_SIZE=3GB
SWAP_PARTITION_SIZE=64
MAIN_POOL_NAME=manna_ssd
MIRROR_POOL_NAME=manna_spin
KEY_BOOT=$(mktemp -p /dev/shm )
KEY_ZFS=$(mktemp -p /dev/shm )
INSTALL_DIR="/mnt/nixos"
NIX_VERSION=20.03
PASSPHRASE_FILE="${DIR}/passphrase.txt"
TRUE=$(which true)
CRYPT_BOOT_DEV=mannassdboot

# Check for nixos dependencies:

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

swapPartition="/dev/zvol/${MAIN_POOL_NAME}/swap"
efiMainPartition="${INSTALL_DEVICE}-part2"
bootPartition="${INSTALL_DEVICE}-part3"
rootPartition="${INSTALL_DEVICE}-part4"

echo
echo "Creating keys"
echo

dd if=/dev/urandom of=$KEY_BOOT bs=1024 count=4
dd if=/dev/urandom of=$KEY_ZFS bs=32 count=1


echo
echo "Cleaning up"
echo

sudo swapoff "${swapPartition}" || ${TRUE}
sudo umount "${INSTALL_DIR}/boot/efi" || ${TRUE}
sudo umount "${INSTALL_DIR}/boot" || ${TRUE}
sudo umount "${INSTALL_DIR}" || ${TRUE}

sudo cryptsetup close $CRYPT_BOOT_DEV || ${TRUE}

if [ -e "${bootPartition}" ]; then
  sudo dd if=/dev/zero of=${bootPartition} bs=2M count=10
fi

sudo zpool destroy "${MAIN_POOL_NAME}" || ${TRUE}
sudo -- sgdisk --zap-all ${INSTALL_DEVICE}
sudo dd if=/dev/zero of=${INSTALL_DEVICE} bs=2M count=10


echo
echo "Partitioning.."
echo

sudo -- parted --script ${INSTALL_DEVICE} -- \
  unit MiB \
  mklabel gpt \
  mkpart primary 1 3 \
  name 1 grub \
  mkpart esp fat32 3 514 \
  name 2 efi \
  mkpart primary 514 3072 \
  name 3 boot \
  mkpart primary 3072 100% \
  set 1 bios_grub on \
  set 2 boot on \


sleep 3

echo
echo "Formatting.."
echo

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
  -O "keylocation=file://${KEY_ZFS}" \
  -O mountpoint=none \
  -O compression=on \
  "${MAIN_POOL_NAME}" \
  "${rootPartition}"

# Reserve some diskspace for copy-on-write if disk is full
sudo zfs create \
  -o refreservation=1G \
  -o mountpoint=none \
  "${MAIN_POOL_NAME}/reserved"

sudo zfs create \
  -V "${SWAP_PARTITION_SIZE}GB" \
  -b "$(getconf PAGESIZE)" \
  -o compression=zle \
  -o logbias=throughput \
  -o sync=always \
  -o primarycache=metadata \
  -o secondarycache=none \
  -o com.sun:auto-snapshot=false \
  "${MAIN_POOL_NAME}/swap"

sudo mkswap -L swap ${swapPartition}

sudo zfs create \
  -o canmount=off \
  -o mountpoint=none \
  "${MAIN_POOL_NAME}/NixOS"

sudo zfs create \
  -o mountpoint=legacy \
  -o canmount=on \
  "${MAIN_POOL_NAME}/NixOS/root"


sudo mkfs.fat -F 32 -n boot "${efiMainPartition}"

sudo cryptsetup luksFormat \
  --batch-mode \
  --type luks1 \
  -c aes-xts-plain64 \
  -s 256 \
  --pbkdf pbkdf2 \
  "${bootPartition}" "${KEY_BOOT}"

sudo cryptsetup luksAddKey \
  --batch-mode \
  --key-file "${KEY_BOOT}" \
  --pbkdf pbkdf2 \
  "${bootPartition}" \
  "${PASSPHRASE_FILE}"

sudo cryptsetup open \
  --type luks \
  --key-file \
  "${KEY_BOOT}" "${bootPartition}" ${CRYPT_BOOT_DEV}

sudo mkfs.ext4 /dev/mapper/${CRYPT_BOOT_DEV}

# echo "Installing.."

sudo mkdir -p "${INSTALL_DIR}"

sudo mount -t zfs "${MAIN_POOL_NAME}/NixOS/root" "${INSTALL_DIR}"
sudo mkdir "${INSTALL_DIR}/boot"
sudo mount /dev/mapper/${CRYPT_BOOT_DEV} "${INSTALL_DIR}/boot"

sudo cp "${KEY_BOOT}" "${INSTALL_DIR}/boot/keyfileBoot.bin"
sudo cp "${KEY_ZFS}" "${INSTALL_DIR}/boot/keyfileZfs.bin"

pushd "${INSTALL_DIR}/boot"
  sudo rm -f "${INSTALL_DIR}/boot/initrd.keys.gz"
  find keyfile*.bin -print0 | sort -z | sudo cpio -o -H newc -R +0:+0 --reproducible --null | gzip -9 | sudo tee "${INSTALL_DIR}/boot/initrd.keys.gz" >/dev/null
  sudo chmod 000 "${INSTALL_DIR}/boot/initrd.keys.gz" "${INSTALL_DIR}/boot/"keyfile*.bin
popd

bootPartitionUuid=$(blkid -o value -s UUID ${bootPartition})
bootPartitionByUuid="/dev/disk/by-uuid/${bootPartitionUuid}"
sudo mkdir "${INSTALL_DIR}/boot/efi"
sudo mount "${efiMainPartition}" "${INSTALL_DIR}/boot/efi"

sudo swapoff -a
sudo swapon "${swapPartition}"
sudo -- `which nixos-generate-config` --root "${INSTALL_DIR}"
sudo swapon -a

sedCmds="--posix "
for replaceVar in INSTALL_DEVICE bootPartitionByUuid CRYPT_BOOT_DEV; do
  sedCmds+=" -e "
  sedCmds+="s\$##$replaceVar##\$$(eval "echo \${$replaceVar}")\$"
done
echo $sedCmds
for sedfile in configuration.nix bootdevice.nix; do
  sed $sedCmds "$DIR/${sedfile}" | \
    sudo tee "${INSTALL_DIR}/etc/nixos/${sedfile}" >/dev/null
done
for filename in dropbox.nix users.nix virtualization.nix x11.nix xscreensaver.nix passwords.nix 79dachboden5.cer; do
  sudo cp "${filename}" "${INSTALL_DIR}/etc/nixos/${filename}"
done

echo "nixos-install"
sudo zfs set keylocation=file:///keyfileZfs.bin "${MAIN_POOL_NAME}"
sudo PATH="$PATH" NIX_PATH="$NIX_PATH" $(which nixos-install) --show-trace --no-root-passwd --root "${INSTALL_DIR}"

